//
//  JourneyController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import MapKit

class JourneyController {
	
//	private static let controller: JourneyController!
	
	// Create the singleton instance
	private static var instance: JourneyController?
	
	static func sharedInstance() -> JourneyController {
		guard let instance = self.instance else {
			self.instance = JourneyController()
			return self.instance!
		}
		
		return instance
	}
	
	// Array that saves Journey instances
	private var journeys = [Journey]()
	
	// Prevent to create another JourneyController instance
	private init() {
		let testTitle = "Test Journey"
		let testStartDate = Date.getDateFromString("2016.10.05")
		let testEndDate = Date.getDateFromString("2016.12.31")
		let emptyAssets = [Date : [TravelAsset]]()
		
		let testSchedules: [Schedule] = [
			Schedule(location: MKPlacemark(
					 coordinate: CLLocationCoordinate2D(latitude: 47.640071, longitude: -122.12959)),
			         startDate: Date.getDateFromString("2016.10.05"),
			         endDate: Date.getDateFromString("2016.10.20"),
			         assets: emptyAssets),
			Schedule(location: MKPlacemark(
					 coordinate: CLLocationCoordinate2D(latitude: 37.778824, longitude: -122.389259)),
			         startDate: Date.getDateFromString("2016.10.20"),
			         endDate: Date.getDateFromString("2016.11.05"),
			         assets: emptyAssets),
			Schedule(location: MKPlacemark(
					 coordinate: CLLocationCoordinate2D(latitude: 37.333092, longitude: -122.030372)),
			         startDate: Date.getDateFromString("2016.11.05"),
			         endDate: Date.getDateFromString("2016.11.17"),
			         assets: emptyAssets),
			Schedule(location: MKPlacemark(
					 coordinate: CLLocationCoordinate2D(latitude: 37.786576, longitude: -122.401067)),
			         startDate: Date.getDateFromString("2016.11.17"),
			         endDate: Date.getDateFromString("2016.12.03"),
			         assets: emptyAssets),
			Schedule(location: MKPlacemark(
					 coordinate: CLLocationCoordinate2D(latitude: 37.484760, longitude: -122.147932)),
			         startDate: Date.getDateFromString("2016.12.03"),
			         endDate: Date.getDateFromString("2016.12.19"),
			         assets: emptyAssets),
			Schedule(location: MKPlacemark(
					 coordinate: CLLocationCoordinate2D(latitude: 38.292761, longitude: -122.458120)),
			         startDate: Date.getDateFromString("2016.12.19"),
			         endDate: Date.getDateFromString("2016.12.31"),
			         assets: emptyAssets)
		]
		
		let testJourney: Journey = Journey(title: testTitle, startDate: testStartDate, endDate: testEndDate, schedules: testSchedules)
		self.journeys.append(testJourney)
	}
	
	// Save new journey instance to the array
	func addJourney(_ journey: Journey) {
		journeys.append(journey)
	}
	
	// Return number of Journey instances in the array
	var count: Int {
		return journeys.count
	}
	
	// Return the Journey instance in the array
	func getJourney(at index: Int) -> Journey {
		return journeys[index]
	}
	
	// Remove Journey instance from the array
	func removeJourney(at index: Int) {
		journeys.remove(at: index)
	}
}
