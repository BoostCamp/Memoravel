//
//  Journey.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import UIKit
import MapKit

/**
Save Journey data - This is the main data structure of this project
*/
class Journey {
	
	var title: String
	var startDate: Date
	var endDate: Date
	var schedules: [Schedule]
	var thumbnailImage: UIImage?
//	var isFetchedAsset: Bool = false
	
	init(title: String, startDate: Date, endDate: Date, schedules: [Schedule]) {
		self.title = title
		self.startDate = startDate
		self.endDate = endDate
		self.schedules = schedules
	}
	
	var numOfSchedules: Int {
		return self.schedules.count
	}
	
	func addNewSchedule(_ schedule: Schedule) {
		self.schedules.append(schedule)
	}
	
	func getSchedule(of index: Int) -> Schedule {
		return self.schedules[index]
	}
	
	func removeSchedule(of index: Int) {
		self.schedules.remove(at: index)
	}
	
	func getCoordinatesOfJourney() -> [CLLocationCoordinate2D] {
		var result = [CLLocationCoordinate2D]()
		
		for schedule in schedules {
			let location: MKPlacemark = schedule.location
			result.append(location.coordinate)
		}
		
		return result
	}
}
