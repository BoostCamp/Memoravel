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
import ReplayKit

class PlayJourneyViewController: UIViewController {
	
	var journey: Journey!
	
	var timer: Timer?
	let widthOfCell: CGFloat = 150.0
	
	var scheduleAssets = [[TravelAsset]]()
	var allAssets = [TravelAsset]()

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var buttonView: UIView!
	
	// MARK: - Properties for animating images
	var progress: CGFloat = 0.0
	var contentWidth: CGFloat = 0.0
	var locationIndex: Int = 0
	var scheduleOffset: [CGFloat] = [0.0]
	
	// MARK: - Properties for Map view
	var polyline: MKGeodesicPolyline?
	var annotations: [MKPointAnnotation]?
	
	// MARK: - Properties for tool bar
	@IBOutlet weak var bottomButton: UIButton!
	
	// MARK: - Properties for Recording
	@IBOutlet weak var closingView: UIView!
	@IBOutlet weak var journeyTitle: UILabel!
	@IBOutlet weak var journeyDate: UILabel!
	
	@IBOutlet weak var heightOfButtonView: NSLayoutConstraint!
	var previewController: RPPreviewViewController?
	var isRecording: Bool = false

	override var prefersStatusBarHidden: Bool {
		return (self.navigationController?.isNavigationBarHidden)!
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set collection view
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		
		// Extract schedule assets from schedules array
		self.appendScheduleAssets()
		
		// Set the delegate of the MKMap
		self.mapView.delegate = self
		self.animateLocationsOnMap(index: 0)
		
		// Settings for closing view
		self.closingView.isHidden = true
		
		self.journeyTitle.text = self.journey.title
		self.journeyDate.text = "\(JourneyDate.formatted(date: self.journey.startDate))-\(JourneyDate.formatted(date: self.journey.endDate))"
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
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
	
	@IBAction func buttonAction(_ sender: UIButton) {
		// Settings when the button is waiting for user action to record
		if sender.title(for: .normal) == "  Start Recording" {
			sender.setTitle("  Stop Recording", for: .normal)
			sender.setImage(#imageLiteral(resourceName: "warning"), for: .normal)
			self.startRecording()
		
		// Settings when the botton is waiting for user to stop recording
		} else if sender.title(for: .normal) == "  Stop Recording" {
			sender.setTitle("  Start Recording", for: .normal)
			sender.setImage(#imageLiteral(resourceName: "recording"), for: .normal)
			self.stopRecording()
		
		// Settings for share button
		} else if sender.title(for: .normal) == "  Check the Output" {
			self.shareVideo()
		}
	}
	
	func startRecording() {
		print("startRecording")
		
		self.navigationController?.isNavigationBarHidden = true
		self.heightOfButtonView.constant = 0.0
		self.isRecording = true
		
		// Prevent user to control collection view and map view
		self.closingView.isHidden = false
		
		// Start recording
		let recorder = RPScreenRecorder.shared()
		
		recorder.startRecording { (error) in
			if let unwrappedError = error {
				print("ERROR: \(unwrappedError)")
			
			} else {
				UIView.animate(withDuration: 3.0, animations: {
					self.closingView.alpha = 0.02
					
				}) { (isFinished) in
					if isFinished {
						self.configAutoScrollTimer()
					}
				}
			}
		}
	}
	
	func stopRecording() {
		print("stopRecording")
		deconfigAutoScrollTimer()
		
		self.closingView.isHidden = true
		self.isRecording = false
		
		self.collectionView.contentOffset.x = 0.0
		self.progress = 0.0
		self.animateLocationsOnMap(index: 0)
		self.navigationController?.isNavigationBarHidden = false
		
		self.heightOfButtonView.constant = 44.0
	}
	
	func shareVideo() {
		// Add share actions
		if let controller = self.previewController {
			self.present(controller, animated: true, completion: nil)
		
		} else {
			print("Could not share the video :-[")
		}
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
	
	// When animation is finished, show the center of schedules location
	public func animateCenterLocationOnMap() {
		let center = JourneyCoordinate.getCenterCoord(LocationPoints: self.journey.getCoordinatesOfJourney())
		let span = MKCoordinateSpanMake(30.0, 30.0)
		let region = MKCoordinateRegionMake(center, span)
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
		print("configAutoScrollTimer")
		self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(autoScrollView), userInfo: nil, repeats: true)
	}
	
	func deconfigAutoScrollTimer() {
		print("deconfigAutoScrollTimer")
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
				print("self.locationIndex: \(self.locationIndex)")
				print("loIndex: \(loIndex)")
				
				self.locationIndex = loIndex
				
				if loIndex != 0 {
					self.animateLocationsOnMap(index: self.locationIndex)
				}
			}
			
			if (self.progress / self.widthOfCell) == self.scheduleOffset[self.locationIndex] {
				self.animateLocationsOnMap(index: self.locationIndex)
				self.locationIndex += 1
			}
			
			if self.progress < self.collectionView.contentSize.width {
				self.progress += 5.0
				self.contentWidth += 5.0
			
			// End of animation
			} else {
				self.deconfigAutoScrollTimer()
				self.journeyTitle.isHidden = true
				self.journeyDate.isHidden = true
				
				self.animateCenterLocationOnMap()
				
				UIView.animate(withDuration: 2.0, animations: {
					self.closingView.alpha = 1.0
					
				}, completion: { (isFinished) in
					if isFinished {
						
						let recorder = RPScreenRecorder.shared()
						recorder.stopRecording { (preview, error) in
							if let unwrappedPreview = preview {
								unwrappedPreview.previewControllerDelegate = self
								self.previewController = unwrappedPreview
								
								// Settings when recording is done successfully
								self.closingView.isHidden = true
								self.isRecording = false
								self.collectionView.contentOffset = CGPoint(x: 0.0, y: 0.0)
								self.animateLocationsOnMap(index: 0)
								
								self.navigationController?.isNavigationBarHidden = false
								
								self.bottomButton.setTitle("  Check the Output", for: .normal)
								self.bottomButton.setImage(#imageLiteral(resourceName: "small_check"), for: .normal)
								self.heightOfButtonView.constant = 44.0
							}
						}
					}
				})
				
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

extension PlayJourneyViewController: RPPreviewViewControllerDelegate {
	
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		self.dismiss(animated: true)
	}
}

extension PlayJourneyViewController {
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.isRecording {
			if self.heightOfButtonView.constant == 0 {
				self.heightOfButtonView.constant = 44
			
			} else {
				self.heightOfButtonView.constant = 0
			}
		}
	}
}
