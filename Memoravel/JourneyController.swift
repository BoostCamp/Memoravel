//
//  JourneyController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation

class JourneyController {
	
//	private static let controller: JourneyController!
	
	// Create the singleton instance
	static let shared: JourneyController = JourneyController()
	
	// Array that saves Journey instances
	private var journeys = [Journey]()
	
	// Prevent to create another JourneyController instance
	private init() {}
	
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
