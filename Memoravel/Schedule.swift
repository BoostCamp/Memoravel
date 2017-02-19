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
class Schedule {
	
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
}
