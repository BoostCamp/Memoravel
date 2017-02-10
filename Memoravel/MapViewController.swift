//
//  MapViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/9/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
	func didSelectedLocation(_ placemark: MKPlacemark)
}

class MapViewController: UIViewController {

	let locationManager = CLLocationManager()
	var resultSearchController: UISearchController!
	var selectedPin: MKPlacemark?
	var delegate: MapViewControllerDelegate?
	var cancelButton: UIButton!
	
	// FIXME: Can uerinputText property change into operational property?
	var userInputText: String?
	
	@IBOutlet weak var searchMapView: MKMapView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
		
		// Wire up search result table
		let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
		resultSearchController = UISearchController(searchResultsController: locationSearchTable)
		resultSearchController.delegate = self
		resultSearchController.searchResultsUpdater = locationSearchTable
		
		// Settings for search bar
		let searchBar = resultSearchController!.searchBar
		searchBar.sizeToFit()
		searchBar.placeholder = "Search for places where you visited"
		searchBar.returnKeyType = .search
		navigationItem.titleView = resultSearchController?.searchBar
		
		resultSearchController.hidesNavigationBarDuringPresentation = false
		resultSearchController.dimsBackgroundDuringPresentation = true
		definesPresentationContext = true
		locationSearchTable.mapView = searchMapView
		locationSearchTable.delegate = self
		
		// Settings for rightBarButton
		cancelButton = UIButton(type: .custom)
		cancelButton.setImage(#imageLiteral(resourceName: "cancel_white"), for: .normal)
		cancelButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		cancelButton.addTarget(self, action: #selector(cancelSearching), for: .touchUpInside)
		cancelButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
	
	// Action when user click cancel button
	func cancelSearching() {
		self.dismiss(animated: true, completion: nil)
	}
}

extension MapViewController : CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			locationManager.requestLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else { return }
		let span = MKCoordinateSpanMake(0.05, 0.05)
		let region = MKCoordinateRegion(center: location.coordinate, span: span)
		searchMapView.setRegion(region, animated: true)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error:: \(error)")
	}
}

// MARK: Implement method for HandleMapSearch

extension MapViewController: LocationSearchTableDelegate {
	
	func dropPinZoomIn(_ placemark: MKPlacemark) {
		// If right bar button item is nil then create it
		if navigationItem.rightBarButtonItem == nil {
			navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
		}
		
		// Cache the pin
		selectedPin = placemark
		
		// Clear existing pins
		searchMapView.removeAnnotations(searchMapView.annotations)
		
		// Create a new annotation
		let annotation = MKPointAnnotation()
		annotation.coordinate = placemark.coordinate
		annotation.title = placemark.name
		
		if let city = placemark.locality, let state = placemark.administrativeArea, let country = placemark.country {
			annotation.subtitle = "\(city) \(state), \(country)"
		}
		
		searchMapView.addAnnotation(annotation)
		
		let span = MKCoordinateSpanMake(0.05, 0.05)
		let region = MKCoordinateRegionMake(placemark.coordinate, span)
		searchMapView.setRegion(region, animated: true)
	}
}

// MARK: - Settings for annotation view

extension MapViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard !(annotation is MKUserLocation) else { return nil }
		
		let reuseId = "pin"
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
		}
		
		pinView?.pinTintColor = UIColor.journeyMainColor
		pinView?.canShowCallout = true
		
		let smallSquare = CGSize(width: 30, height: 30)
		let confirmButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
		confirmButton.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
		confirmButton.addTarget(self, action: #selector(confirmLocation), for: .touchUpInside)
		pinView?.rightCalloutAccessoryView = confirmButton
		
		return pinView
	}

	func confirmLocation() {		
		if let delegate = self.delegate, let placemark = self.selectedPin {
			delegate.didSelectedLocation(placemark)
			self.dismiss(animated: true, completion: nil)
		}
	}
}

// MARK: - Settings for UISearchController

extension MapViewController: UISearchControllerDelegate {
	
	func willPresentSearchController(_ searchController: UISearchController) {
		navigationItem.rightBarButtonItem = nil
	}
	
	func willDismissSearchController(_ searchController: UISearchController) {
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
		
		if let text = searchController.searchBar.text {
			userInputText = text
		}
	}
	
	func didDismissSearchController(_ searchController: UISearchController) {
		if let text = userInputText {
			searchController.searchBar.text = text
		}
	}
}

