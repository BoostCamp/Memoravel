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
class Journey: NSObject, NSCoding {
	
	var title: String
	var startDate: Date
	var endDate: Date
	var schedules: [Schedule]
	var thumbnailImage: UIImage
	
	init(title: String, startDate: Date, endDate: Date, schedules: [Schedule], thumbnailImage: UIImage) {
		self.title = title
		self.startDate = startDate
		self.endDate = endDate
		self.schedules = schedules
		self.thumbnailImage = thumbnailImage
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
	
	required convenience init(coder aDecoder: NSCoder) {
		let title = aDecoder.decodeObject(forKey: "title") as! String
		let startDate = aDecoder.decodeObject(forKey: "startDate") as! Date
		let endDate = aDecoder.decodeObject(forKey: "endDate") as! Date
		let schedules = aDecoder.decodeObject(forKey: "schedules") as! [Schedule]
		let thumbnailImage = aDecoder.decodeObject(forKey: "thumbnailImage") as! UIImage
		
		self.init(title: title, startDate: startDate, endDate: endDate, schedules: schedules, thumbnailImage: thumbnailImage)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(startDate, forKey: "startDate")
		aCoder.encode(endDate, forKey: "endDate")
		aCoder.encode(schedules, forKey: "schedules")
		aCoder.encode(thumbnailImage, forKey: "thumbnailImage")
	}
}
