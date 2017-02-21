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
	private init() { }
	
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
	
	// Save Journey data when the user gets out of the application
	func saveJourneys() {
		let userDefaults = UserDefaults.standard
		let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.journeys)
		userDefaults.set(encodedData, forKey: "JourneyData")
		userDefaults.synchronize()
		
		let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		
		print(documentDirectory)
	}
	
	// Get Journey data when the user starts the application initially
	func getJourneys() {
		let userDefaults = UserDefaults.standard
		if let decodedData: Data = userDefaults.object(forKey: "JourneyData") as? Data {
			let journeys = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [Journey]
			self.journeys = journeys
		}
	}
}
