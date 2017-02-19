//
//  JourneyAddress.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/9/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import MapKit

class JourneyAddress {
	
	// Parse MKPlacemark for title of Asset View
	class func parseTitleAddress(_ selectedItem: MKPlacemark) -> String? {
		return selectedItem.locality
	}
	
	// Parse MKPlacemark to brief address
	class func parseBriefAddress(_ selectedItem: MKPlacemark) -> String {
		
		// Put a space between city and state
		let space = (selectedItem.locality != nil && selectedItem.administrativeArea != nil) ? " " : ""
		
		// Put a comma between city/state and country
		let comma = (selectedItem.locality != nil || selectedItem.administrativeArea != nil)
			&& (selectedItem.country != nil) ? ", " : ""
		
		let addressLine = String(format:"%@%@%@%@%@",
			// City
			selectedItem.locality ?? "",
			space,
			// State
			selectedItem.administrativeArea ?? "",
			comma,
			// Country code
			selectedItem.countryCode ?? ""
		)
		
		return addressLine
	}
	
	// Parse MKPlacemark to detail address
	class func parseDetailAddress(_ selectedItem: MKPlacemark) -> String {
		
		// Put a space between street number and street name
		let spaceStreet = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
		
		// Put a comma between street name and city
		let commaStreetAndCity = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil)
			&& (selectedItem.locality != nil || selectedItem.administrativeArea != nil) ? ", " : ""
		
		// Put a space between city and administrative area
		let spaceCity = (selectedItem.locality != nil && selectedItem.administrativeArea != nil) ? " " : ""
		
		// Put a comma between city and country
		let commaCityAndCountry = (selectedItem.locality != nil || selectedItem.administrativeArea != nil)
			&& (selectedItem.country != nil) ? ", " : ""
		
		let addressLine = String(format: "%@%@%@%@%@%@%@%@%@",
		    // Street Number
			selectedItem.subThoroughfare ?? "",
			spaceStreet,
			// Street name
			selectedItem.thoroughfare ?? "",
			commaStreetAndCity,
			// City
			selectedItem.locality ?? "",
			spaceCity,
			// State
			selectedItem.administrativeArea ?? "",
			commaCityAndCountry,
			// Country
			selectedItem.country ?? ""
		)
		
		return addressLine
	}
}
