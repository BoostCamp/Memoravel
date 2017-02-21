//
//  Schedule.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import MapKit

/**
Save schedules of a Journey
*/
class Schedule: NSObject, NSCoding {
	
	var location: MKPlacemark
	var startDate: Date
	var endDate: Date
	var assetsDict: [Date : [TravelAsset]]
	
	init(location: MKPlacemark, startDate: Date, endDate: Date, assets: [Date : [TravelAsset]]) {
		self.location = location
		self.startDate = startDate
		self.endDate = endDate
		self.assetsDict = assets
	}
	
	required convenience init(coder aDecoder: NSCoder) {
		let location = aDecoder.decodeObject(forKey: "location") as! MKPlacemark
		let startDate = aDecoder.decodeObject(forKey: "startDate") as! Date
		let endDate = aDecoder.decodeObject(forKey: "endDate") as! Date
		let assetsDict = aDecoder.decodeObject(forKey: "assetsDict") as! [Date : [TravelAsset]]
		
		self.init(location: location, startDate: startDate, endDate: endDate, assets: assetsDict)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(location, forKey: "location")
		aCoder.encode(startDate, forKey: "startDate")
		aCoder.encode(endDate, forKey: "endDate")
		aCoder.encode(assetsDict, forKey: "assetsDict")
	}
}
