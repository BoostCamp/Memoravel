//
//  LocationSearchTable.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/9/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchTableDelegate {
	func dropPinZoomIn(_ placemark: MKPlacemark)
}

class LocationSearchTable: UITableViewController {
	
	var mapView: MKMapView?
	var matchingItems: [MKMapItem] = []
	var delegate: LocationSearchTableDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set blur effect to this table view
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		blurEffectView.frame = tableView.frame
		tableView.insertSubview(blurEffectView, at: 0)
    }
}

extension LocationSearchTable : UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		guard let mapView = mapView,
			let searchBarText = searchController.searchBar.text else { return }
		
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = searchBarText
		request.region = mapView.region
		let search = MKLocalSearch(request: request)
		
		search.start { response, _ in
			guard let response = response else {
				return
			}
			self.matchingItems = response.mapItems
			self.tableView.reloadData()
		}
	}
}

extension LocationSearchTable {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matchingItems.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell")!
		let selectedItem = matchingItems[indexPath.row].placemark
		cell.textLabel?.text = selectedItem.name
		cell.detailTextLabel?.text = JourneyAddress.parseAddress(selectedItem)
		return cell
	}
}

extension LocationSearchTable {
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedItem = matchingItems[indexPath.row].placemark
		if let delegate = self.delegate {
			delegate.dropPinZoomIn(selectedItem)
			dismiss(animated: true, completion: nil)
		}
		
	}	
}

