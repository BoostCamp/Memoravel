//
//  PlayJourneyViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/27/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import Photos
import MapKit
import ReplayKit

class PlayJourneyViewController: UIViewController {
	
	var journey: Journey!
	var schedules: [Schedule]!
	var resultAssets: [MKPlacemark : [TravelAsset]]!
	
	// 모든 이미지를 collection view 에 담아서 보여줘야 하므로, 이미지를 하나의 배열에 저장
	var allAssets = [TravelAsset]()
	
	// Collection view 를 auto scrolling 하기 위한 properties 를 정의
	var timer: Timer?
	var progress: CGFloat = 0.0
	var contentWidth: CGFloat = 0.0
	var locationIndex: Int = 0
	var scheduleOffset: [CGFloat] = [0.0]
	var widthOfCell: CGFloat = 220.0
	
	// MapView 에 annotations 과 polyline 을 그리기 위한 properties 를 정의
	var polyline: MKGeodesicPolyline?
	var annotations: [MKPointAnnotation]?
	
	// Closing view 와 관련된 properties
	@IBOutlet weak var closingView: UIView!
	@IBOutlet weak var journeyTitle: UILabel!
	@IBOutlet weak var journeyDate: UILabel!
	
	// View Recording 과 관련된 properties 를 정의
	var previewController: RPPreviewViewController?
	var isRecording: Bool = false
	
	// Recording 을 시작하면, navigation bar 와 status bar 를 모두 hide
	override var prefersStatusBarHidden: Bool {
		return (self.navigationController?.isNavigationBarHidden)!
	}
	
	// Bottom view 와 관련된 properties 를 정의
	@IBOutlet weak var bottomButton: UIButton!
	@IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Collection view 의 기본 세팅
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		
		// Map view 의 기본 세팅
		self.mapView.delegate = self
		self.animateLocationsOnMap(index: 0)
		
		// Closing view 의 기본 세팅
		self.closingView.isHidden = true
		self.journeyTitle.text = self.journey.title
		self.journeyDate.text = "\(JourneyDate.formatted(date: self.journey.startDate))-\(JourneyDate.formatted(date: self.journey.endDate))"
		
		// resultAssets 에서 모든 TravelAssets 을 allAssets 배열에 저장한다
		self.appendAllAssetsInArray()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.deconfigAutoScrollTimer()
		
		// Delete all overlays of Map view
		for overlay in self.mapView.overlays {
			self.mapView.remove(overlay)
		}
		
		// Delete all annotations of Map view
		for annotation in self.mapView.annotations {
			self.mapView.removeAnnotation(annotation)
		}
	}
	
	@IBAction func bottomButtonAction(_ sender: UIButton) {
		// Settings when the button is waiting for user action to record
		if sender.title(for: .normal) == "  Start Recording" {
			sender.setTitle("  Stop Recording", for: .normal)
			sender.setImage(#imageLiteral(resourceName: "warning"), for: .normal)
			self.startRecording()
			
			// Settings when the botton is waiting for user to stop recording
		} else if sender.title(for: .normal) == "  Stop Recording" {
			print("button is touched by the user")
			sender.setTitle("  Start Recording", for: .normal)
			sender.setImage(#imageLiteral(resourceName: "recording"), for: .normal)
			self.stopRecording()
			
			// Settings for share button
		} else if sender.title(for: .normal) == "  Check the Output" {
			self.shareVideo()
		}
	}
	
	func appendAllAssetsInArray() {
		// TravelAssets 을 append 할 때, 사용자의 여행 경로 순으로 append 를 해야한다.
		for schedule in self.schedules {
			if let assets = self.resultAssets[schedule.location] {
				print("\(JourneyAddress.parseTitleAddress(schedule.location)!) 의 assets 을 배열에 저장합니다.")
				for asset in assets {
					self.allAssets.append(asset)
				}
				
				let previousIndex: Int = self.scheduleOffset.count - 1
				let offsetValue: CGFloat = CGFloat(assets.count) + self.scheduleOffset[previousIndex]
				self.scheduleOffset.append(offsetValue)
			}
		}
		
		print("allAssets 에 저장된 assets 의 개수: \(self.allAssets.count)")
	}
}

// MARK: - Recording 과 연관된 전반적인 함수들을 정의

extension PlayJourneyViewController {
	
	// 사용자가 녹화를 시작할 때 호출되는 함수
	func startRecording() {
		self.navigationController?.isNavigationBarHidden = true
		self.bottomViewHeight.constant = 0.0
		self.isRecording = true
		
		// 녹화가 시작되었을 때 사용자가 지도와 사진을 건드리지 못하도록 closing view 활성화
		self.closingView.isHidden = false
		self.journeyTitle.isHidden = false
		self.journeyDate.isHidden = false
		
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
						self.journeyTitle.isHidden = true
						self.journeyDate.isHidden = true
					}
				}
			}
		}
	}
	
	// 사용자가 녹화를 중간에 그만둘 때 호출되는 함수
	func stopRecording() {
		let recorder = RPScreenRecorder.shared()
		if recorder.isRecording {
			recorder.stopRecording(handler: { (previewController, error) in
				if let unwrappedError = error {
					print("ERROR: \(unwrappedError.localizedDescription)")
					
				} else {
					// Settings when the user stops recording
					self.deconfigAutoScrollTimer()
					
					self.journeyTitle.isHidden = false
					self.journeyDate.isHidden = false
					self.closingView.isHidden = true
					self.closingView.alpha = 1.0
					
					self.isRecording = false
					self.collectionView.contentOffset = CGPoint(x: 0.0, y: 0.0)
					self.progress = 0.0
					self.contentWidth = 0.0
					self.locationIndex = 0
					
					self.animateLocationsOnMap(index: 0)
					self.navigationController?.isNavigationBarHidden = false
					
					self.bottomViewHeight.constant = 44.0
				}
			})
		}
	}
	
	// 사용자가 녹화를 마치고 비디오를 공유할 때 호출되는 함수
	func shareVideo() {
		// Add share actions
		if let controller = self.previewController {
			self.present(controller, animated: true, completion: nil)
			
		} else {
			print("Could not share the video :-[")
		}
	}
}

extension PlayJourneyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.allAssets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayImageCell", for: indexPath)
		
		let travelAsset: TravelAsset = self.allAssets[indexPath.row]
		if let playCell = cell as? PlayImageCollectionViewCell {
			PHImageManager.default().requestImage(for: travelAsset.asset!, targetSize: playCell.imageView.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
				playCell.imageView.image = image
			})
		}
		
		return cell
	}
}

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
		var coordinates = [CLLocationCoordinate2D]()
		var schedules = [Schedule]()
		
		// 사용자가 선택한 asset 의 장소를 coordinates 로 변환하여 배열에 저장
		for schedule in self.schedules {
			if self.resultAssets[schedule.location] != nil {
				let coordinate = schedule.location.coordinate
				coordinates.append(coordinate)
				schedules.append(schedule)
			}
		}
		
		// 기존에 MapView 에 입력한 annotations 과 polylines 이 없다면, 새로 만들어준다.
		if (self.mapView.annotations.count == 0) && (self.mapView.overlays.count == 0) {
			var annotations = [MKPointAnnotation]()
			
			// annotations 을 map view 에 추가
			for schedule in schedules {
				let selectedLocation: MKPlacemark = schedule.location
				let annotation = MKPointAnnotation()
				annotation.coordinate = selectedLocation.coordinate
				annotation.title = selectedLocation.name
				
				if let city = selectedLocation.locality, let state = selectedLocation.administrativeArea, let country = selectedLocation.country {
					annotation.subtitle = "\(city) \(state), \(country)"
				}
				
				annotations.append(annotation)
				self.annotations = annotations
			}
			
			self.mapView.addAnnotations(annotations)
			
			// polyline 을 map view 에 추가
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
	
	public func animateCenterLocationOnMap() {
		var coordinates = [CLLocationCoordinate2D]()
		
		// 사용자가 선택한 asset 의 장소를 coordinates 로 변환하여 배열에 저장
		for schedule in self.schedules {
			if self.resultAssets[schedule.location] != nil {
				let coordinate = schedule.location.coordinate
				coordinates.append(coordinate)
			}
		}
		
		let center = JourneyCoordinate.getCenterCoord(LocationPoints: coordinates)
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

// MARK: - Collection view 가 자동으로 스크롤 될 수 있도록 한다.

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
				
				if loIndex != 0 {
					self.animateLocationsOnMap(index: self.locationIndex)
				}
			}
			
			if (self.progress / self.widthOfCell) == self.scheduleOffset[self.locationIndex] {
				self.animateLocationsOnMap(index: self.locationIndex)
				self.locationIndex += 1
			}
			
			if self.progress < self.collectionView.contentSize.width {
				// animation 이 진행 중인 상태
				self.progress += 5.0
				self.contentWidth += 5.0
			
			} else {
				// animation 이 끝난 상태
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
								self.bottomViewHeight.constant = 44.0
							}
						}
					}
				})
				
				return
			}
			
			let offsetPoint: CGPoint = CGPoint(x: self.progress, y: 0.0)
			self.collectionView.contentOffset = offsetPoint
			
		} else {
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

extension PlayJourneyViewController: RPPreviewViewControllerDelegate {
	
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		self.dismiss(animated: true)
	}
}

extension PlayJourneyViewController {
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.isRecording {
			if self.bottomViewHeight.constant == 0 {
				self.bottomViewHeight.constant = 44
				
			} else {
				self.bottomViewHeight.constant = 0
			}
		}
	}
}
