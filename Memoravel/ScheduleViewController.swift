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
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var waitView: UIView!
	@IBOutlet weak var activityView: UIActivityIndicatorView!
	@IBOutlet weak var toolBar: UIToolbar!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and dataSource of UITableView
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		// Set navigation title
		self.navigationItem.title = self.journey.title
		
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
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			confirmDelete(at: indexPath.row)
		}
	}
	
	func confirmDelete(at index: Int) {
		let alertController: UIAlertController
		
		// Force not to delete when there's only one schedule in the journey
		if self.journey.schedules.count > 1 {
			alertController = UIAlertController(
				title: "Delete main schedule",
				message: "Are you sure you want to delete this schedule?",
				preferredStyle: .actionSheet
			)
			
			let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
				self.journey.removeSchedule(of: index)
				self.tableView.reloadData()
				self.dismiss(animated: true, completion: nil)
			}
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
				self.dismiss(animated: true, completion: nil)
			}
			
			alertController.addAction(deleteAction)
			alertController.addAction(cancelAction)
		
		} else {
			alertController = UIAlertController(
				title: "Cannot delete schedule",
				message: "You can't delete a schedule when there's only one schedule in the journey",
				preferredStyle: .alert
			)
			
			let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
				self.dismiss(animated: true, completion: nil)
			}
			
			alertController.addAction(okAction)
		}
		
		self.present(alertController, animated: true, completion: nil)
	}
}

// MARK: - Load asset data and save it to the data structure

extension ScheduleViewController {
	
	func saveAssetsToMainSchedule() {
		
		// Check whether this method is called twice
		if self.journey.isFetchedAsset { return }
		
		let fetchOption = PHFetchOptions()
		self.activityView.startAnimating()
		
		self.journey.schedules = self.journey.schedules.map {
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
		self.journey.isFetchedAsset = true
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
		let schedule: Schedule = self.journey.getSchedule(of: index)
		
		let annotation = MKPointAnnotation()
		let location: MKPlacemark = schedule.location
		
		annotation.coordinate = location.coordinate
		annotation.title = location.name
		
		if let city = location.locality, let state = location.administrativeArea, let country = location.country {
			annotation.subtitle = "\(city) \(state), \(country)"
		}
		
		self.mapView.addAnnotation(annotation)
		self.mapView.selectAnnotation(annotation, animated: true)
		
		let span = MKCoordinateSpanMake(0.05, 0.05)
		let region = MKCoordinateRegionMake(location.coordinate, span)
		self.mapView.setRegion(region, animated: true)
	}
}
