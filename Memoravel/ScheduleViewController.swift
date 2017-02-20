//
//  ScheduleViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit
import Photos

class ScheduleViewController: UIViewController {

	var journey: Journey!
	
	// Properties for Map view
	var polyline: MKGeodesicPolyline?
	var annotations: [MKPointAnnotation]?
	
	@IBOutlet weak var backgroundCardView: UIView!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var waitView: UIView!
	@IBOutlet weak var activityView: UIActivityIndicatorView!
	@IBOutlet weak var toolBar: UIToolbar!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set the background card with with a shadow, so it looks like a card view
		backgroundCardView.backgroundColor = UIColor.journeyMainColor
		backgroundCardView.layer.cornerRadius = 3.0
		backgroundCardView.layer.masksToBounds = false
		
		// Settings for shadow of background view
		backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
		backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
		backgroundCardView.layer.shadowOpacity = 0.8

        // Set the delegate and dataSource of UITableView
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		// Generate assets and save it to the data structure
		DispatchQueue.global().async {
			self.saveAssetsToMainSchedule()
			self.performUpdate {
				self.waitView.isHidden = true
			}
		}
		
		// Set Play Journey button in the tool bar
		let playJourneyButton: UIButton = UIButton()
		playJourneyButton.setImage(#imageLiteral(resourceName: "video-player"), for: .normal)
		playJourneyButton.setTitle("  Play Journey", for: .normal)
		playJourneyButton.setTitleColor(UIColor.journeyMainColor, for: .normal)
		playJourneyButton.titleLabel?.font = UIFont(name: "Apple SD Gothic Neo", size: 15.0)
		playJourneyButton.addTarget(self, action: #selector(callPlayJourneyModal), for: .touchUpInside)
		playJourneyButton.sizeToFit()
		
		self.toolBar.items = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(customView: playJourneyButton),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		]
		
		// Setting for initial map view
		self.mapView.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Set navigation title
		self.navigationItem.title = self.journey.title
		
		// First location to show in the map
		self.showLocationOfTheSchedule(at: 0)
	}
	
	// MARK: - Method for calling modal view for playing journey schedules
	
	public func callPlayJourneyModal() {
		if let controller = self.storyboard?.instantiateViewController(withIdentifier: "PlayJourneyViewController") as? PlayJourneyViewController {
			controller.schedules = self.journey.schedules
			
			let navController = UINavigationController(rootViewController: controller)
			navController.navigationBar.barTintColor = UIColor.journeyMainColor
			navController.navigationBar.tintColor = UIColor.journeyLightColor
			navController.navigationBar.barStyle = .black
			navController.navigationBar.isTranslucent = false
			
			self.present(navController, animated: true, completion: nil)
		}
	}
	
	// Edit Journey schedules
	@IBAction func editJourneySchedule(_ sender: Any) {
		if let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditJourneyViewController") as? EditJourneyViewController {
			controller.journey = self.journey
			controller.delegate = self
			
			let navController = UINavigationController(rootViewController: controller)
			navController.navigationBar.barTintColor = UIColor.journeyMainColor
			navController.navigationBar.tintColor = UIColor.journeyLightColor
			navController.navigationBar.barStyle = .black
			navController.navigationBar.isTranslucent = false
			
			self.present(navController, animated: true, completion: nil)
		}
	}
}

// MARK: - Implement methods of UITableViewDataSource, UITableViewDelegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.journey.numOfSchedules
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath)
		
		if let scheduleCell = cell as? SchedulesTableViewCell {
			let schedule: Schedule = self.journey.getSchedule(of: indexPath.row)
			let startDate: String = JourneyDate.formatted(date: schedule.startDate)
			let endDate: String = JourneyDate.formatted(date: schedule.endDate)
			
			scheduleCell.locationLabel.text = JourneyAddress.parseDetailAddress(schedule.location)
			scheduleCell.dateLabel.text = startDate + " - " + endDate
			scheduleCell.showLocationButton.tag = indexPath.row
			scheduleCell.showLocationAction = self.showLocationOfTheSchedule(at:)
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("SELECTED A ROW IN SCHEDULE VIEW")
		performSegue(withIdentifier: "ShowAssetView", sender: self.journey.getSchedule(of: indexPath.row))
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? AssetViewController, let schedule = sender as? Schedule {
			controller.schedule = schedule
		}
	}
}

// MARK: - Load asset data and save it to the data structure

extension ScheduleViewController {
	
	func saveAssetsToMainSchedule() {
		
		// Check whether this method is called twice
//		if self.journey.isFetchedAsset { return }
		
		let fetchOption = PHFetchOptions()
		self.activityView.startAnimating()
		
		self.journey.schedules = self.journey.schedules.map {
			
			if $0.assetsDict.count != 0 {
				print("Already have AssetsDict in this schedule")
				return $0
			}
			
			let startDate = $0.startDate
			let endDate = $0.endDate
			var date: Date = startDate
			var assetDict = [Date : [TravelAsset]]()
			var assets = [TravelAsset]()
			
			while date <= endDate {
				// TODO: DELETE THIS TEST CODE
				print("Get images taken on \(date)")
				
				let nextDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
				fetchOption.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", date as NSDate, nextDate as NSDate)
				let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: fetchOption)
				
				for index in 0..<fetchResult.count {
					assets.append(TravelAsset(asset: fetchResult[index], isLike: false, comment: nil))
				}
				
				assetDict[date] = assets
				
				// TODO: DELETE THIS TEST CODE
				print("Fetching images completed :-]")
				
				date = nextDate
				assets = []
			}
			
			$0.assetsDict = assetDict
			return $0
		}
		
		self.activityView.stopAnimating()
//		self.journey.isFetchedAsset = true
	}
	
	func performUpdate(_ updates: @escaping() -> Void) {
		DispatchQueue.main.async {
			updates()
		}
	}
}

// MARK: - Extension for handling Map view

extension ScheduleViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard !(annotation is MKUserLocation) else { return nil }
		
		let reuseId = "pin"
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
		}
		
		pinView?.pinTintColor = UIColor.journeyMainColor
		pinView?.canShowCallout = true
		
		return pinView
	}
	
	func showLocationOfTheSchedule(at index: Int) {
		var coordinates: [CLLocationCoordinate2D] = self.journey.getCoordinatesOfJourney()
		
		if (self.mapView.annotations.count == 0) && (self.mapView.overlays.count == 0) {
			var annotations = [MKPointAnnotation]()
			let schedules: [Schedule] = self.journey.schedules
		
			// Append all annotations of the schedules
			for schedule in schedules {
				let location: MKPlacemark = schedule.location
				let annotation = MKPointAnnotation()
				annotation.coordinate = location.coordinate
				annotation.title = location.name
				
				if let city = location.locality, let state = location.administrativeArea, let country = location.country {
					annotation.subtitle = "\(city) \(state), \(country)"
				}
				
				annotations.append(annotation)
				self.annotations = annotations
			}
			
			self.mapView.addAnnotations(annotations)

			// Draw polyline on the map
			let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
			self.mapView.add(polyline)
			self.polyline = polyline
		}
		
		// Show annotations automatically on the map
		self.mapView.selectAnnotation((self.annotations?[index])!, animated: true)
		
		// Zoom in selected location on the map
		let span = MKCoordinateSpanMake(2.0, 2.0)
		let region = MKCoordinateRegionMake(coordinates[index], span)
		self.mapView.setRegion(region, animated: true)
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is MKPolyline {
			let lenderer = MKPolylineRenderer(overlay: overlay);
			lenderer.strokeColor = UIColor.journeyWarningColor.withAlphaComponent(0.7)
			lenderer.lineWidth = 5.0
			return lenderer
		}
		
		return MKOverlayRenderer()
	}
}

// MARK: - Implement method of EditJourneyViewControllerDelegate

extension ScheduleViewController: EditJourneyViewControllerDelegate {
	
	func finishEditingNewJourney() {
		self.waitView.isHidden = false
		
		// Generate assets and save it to the data structure if the schedule has been changed
		DispatchQueue.global().async {
			self.saveAssetsToMainSchedule()
			self.performUpdate {
				self.waitView.isHidden = true
				
				// Delete all overlays of Map view
				for overlay in self.mapView.overlays {
					self.mapView.remove(overlay)
				}
				
				// Delete all annotations of Map view
				for annotation in self.mapView.annotations {
					self.mapView.removeAnnotation(annotation)
				}

				self.showLocationOfTheSchedule(at: 0)
				self.tableView.reloadData()
			}
		}
	}
}
