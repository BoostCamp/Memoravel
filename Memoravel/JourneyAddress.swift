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
	
	class func parseAddress(_ selectedItem: MKPlacemark) -> String {
		
		// Put a space between city and state
		let space = (selectedItem.locality != nil &&
			selectedItem.administrativeArea != nil) ? " " : ""
		
		// Put a comma between city/state and country
		let comma = (selectedItem.locality != nil || selectedItem.administrativeArea != nil) &&
			selectedItem.country != nil ? ", " : ""
		
		let addressLine = String(
			format:"%@%@%@%@%@",
			// City
			selectedItem.locality ?? "",
			space,
			// State
			selectedItem.administrativeArea ?? "",
			comma,
			selectedItem.countryCode ?? ""
		)
		
		return addressLine
	}
}
