//
//  PlayJourneyViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/18/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit
import Photos

class PlayJourneyViewController: UIViewController {
	
//	var schedules: [Schedule]!
	var journey: Journey!
	
	var timer: Timer?
	let widthOfCell: CGFloat = 150.0
	
	var scheduleAssets = [[TravelAsset]]()
	var allAssets = [TravelAsset]()

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	// Properties for animating images
	var progress: CGFloat = 0.0
	var contentWidth: CGFloat = 0.0
	var locationIndex: Int = 0
	var scheduleOffset: [CGFloat] = [0.0]
	
	// Properties for Map view
	var polyline: MKGeodesicPolyline?
	var annotations: [MKPointAnnotation]?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set collection view
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		
		// Extract schedule assets from schedules array
		self.appendScheduleAssets()
//		self.animateLocationsOnMap(index: 0)
		
		// Set the delegate of the MKMap
		self.mapView.delegate = self
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		configAutoScrollTimer()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		deconfigAutoScrollTimer()
		
		// Delete all overlays of Map view
		for overlay in self.mapView.overlays {
			self.mapView.remove(overlay)
		}
		
		// Delete all annotations of Map view
		for annotation in self.mapView.annotations {
			self.mapView.removeAnnotation(annotation)
		}
	}
	
	@IBAction func closeModal(_ sender: Any) {
		self.timer?.invalidate()
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Methods for handling Map view

extension PlayJourneyViewController: MKMapViewDelegate {
	
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
	
	public func animateLocationsOnMap(index: Int) {
//		let location: MKPlacemark = self.schedules[index].location
//		
//		let annotation = MKPointAnnotation()
//		annotation.coordinate = location.coordinate
//		annotation.title = location.name
//		
//		if let city = location.locality, let state = location.administrativeArea, let country = location.country {
//			annotation.subtitle = "\(city) \(state), \(country)"
//		}
//		
//		print("LOCATION: \(location.name!)")
//		
//		self.mapView.addAnnotation(annotation)
//		self.mapView.selectAnnotation(annotation, animated: true)
//		
//		let span = MKCoordinateSpanMake(2.0, 2.0)
//		let region = MKCoordinateRegionMake(location.coordinate, span)
//		self.mapView.setRegion(region, animated: true)
		
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

// MARK: - Implement methods of UICollectionViewDelegate and UICollectionViewDataSource

extension PlayJourneyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.allAssets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayImageCell", for: indexPath) as! PlayImageCollectionViewCell
		
		let travelAsset: TravelAsset = self.allAssets[indexPath.row]
		PHImageManager.default().requestImage(for: travelAsset.asset!, targetSize: cell.imageView.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
			cell.imageView.image = image
		})
		
		return cell
	}
}

// MARK: - Methods for auto scrolling of UICollectionView

extension PlayJourneyViewController {
	
	func configAutoScrollTimer() {
		self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(autoScrollView), userInfo: nil, repeats: true)
	}
	
	func deconfigAutoScrollTimer() {
		self.timer?.invalidate()
	}
	
	func onTimer() {
		self.autoScrollView()
	}
	
	func autoScrollView() {
		let initialPoint = CGPoint(x: self.progress, y: 0.0)
		
		if __CGPointEqualToPoint(initialPoint, self.collectionView.contentOffset) {
			let loIndex: Int = self.checkLocationIndex(self.progress / self.widthOfCell)
			
			if self.locationIndex != loIndex {
				self.locationIndex = loIndex
				self.animateLocationsOnMap(index: self.locationIndex)
			}
			
			if (self.progress / self.widthOfCell) == self.scheduleOffset[self.locationIndex] {
				self.animateLocationsOnMap(index: self.locationIndex)
				self.locationIndex += 1
				
			}
			
			if self.progress < self.collectionView.contentSize.width {
				self.progress += 5.0
				self.contentWidth += 5.0
			
			} else {
				deconfigAutoScrollTimer()
				self.collectionView.contentOffset = CGPoint(x: 0.0, y: 0.0)
				self.animateLocationsOnMap(index: 0)
				return
			}
			
			let offsetPoint: CGPoint = CGPoint(x: self.progress, y: 0.0)
			self.collectionView.contentOffset = offsetPoint
		
		} else {
			// If the user scrolls collection view, set contentOffset again
			self.collectionView.contentOffset.x -= self.collectionView.contentOffset.x.truncatingRemainder(dividingBy: 5.0)
			self.progress = self.collectionView.contentOffset.x
		}
	}
	
	func checkLocationIndex(_ location: CGFloat) -> Int {
		for index in 0..<self.scheduleOffset.count {
			if location < self.scheduleOffset[index] {
				return index - 1
			}
		}
		
		return 0
	}
}

// MARK: - Methods to prepare animation

extension PlayJourneyViewController {
	
	func appendScheduleAssets() {
		for schedule in self.journey.schedules {
			var aScheduleAsset = [TravelAsset]()
			let keys = schedule.assetsDict.keys
			
			for key in keys {
				let travelAssets: [TravelAsset] = schedule.assetsDict[key]!
				for asset in travelAssets {
					aScheduleAsset.append(asset)
					self.allAssets.append(asset)
				}
			}
			
			self.scheduleAssets.append(aScheduleAsset)
			
			let previousIndex: Int = self.scheduleOffset.count - 1
			let offsetValue: CGFloat = CGFloat(aScheduleAsset.count) + self.scheduleOffset[previousIndex]
			self.scheduleOffset.append(offsetValue)
		}
	}
}
