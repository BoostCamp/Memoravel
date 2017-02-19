//
//  PlayJourneyViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/18/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit

class PlayJourneyViewController: UIViewController {
	
	var schedules: [Schedule]!
	var timer: Timer?
	var loIndex: Int = 0

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set collection view
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		
		// Set initial map status
		let annotation = MKPointAnnotation()
		let location: MKPlacemark = self.schedules[self.loIndex].location
		
		annotation.coordinate = location.coordinate
		annotation.title = location.name
		
		if let city = location.locality, let state = location.administrativeArea, let country = location.country {
			annotation.subtitle = "\(city) \(state), \(country)"
		}
		
		print("LOCATION: \(location.name!)")
		
		self.mapView.addAnnotation(annotation)
		self.mapView.selectAnnotation(annotation, animated: true)
		
		let span = MKCoordinateSpanMake(0.05, 0.05)
		let region = MKCoordinateRegionMake(location.coordinate, span)
		self.mapView.setRegion(region, animated: true)

        // Set Timer
		self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.animateLocationsOnMap), userInfo: nil, repeats: true)
    }
	
	public func animateLocationsOnMap() {
		
		self.loIndex = (self.loIndex + 1 < self.schedules.count) ? self.loIndex + 1 : 0
		let location: MKPlacemark = self.schedules[self.loIndex].location
		
		let annotation = MKPointAnnotation()
		annotation.coordinate = location.coordinate
		annotation.title = location.name
		
		if let city = location.locality, let state = location.administrativeArea, let country = location.country {
			annotation.subtitle = "\(city) \(state), \(country)"
		}
		
		print("LOCATION: \(location.name!)")
		
		self.mapView.addAnnotation(annotation)
		self.mapView.selectAnnotation(annotation, animated: true)
		
		let span = MKCoordinateSpanMake(0.05, 0.05)
		let region = MKCoordinateRegionMake(location.coordinate, span)
		self.mapView.setRegion(region, animated: true)
	}
	
	@IBAction func closeModal(_ sender: Any) {
		self.timer?.invalidate()
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Implement methods of UICollectionViewDelegate and UICollectionViewDataSource

extension PlayJourneyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayImageCell", for: indexPath)
		return cell
	}
}
