//
//  JourneyDate.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation

class JourneyDate {
	
	private static let dateFormatter = DateFormatter()
	
	// Prevent to create a new JourneyDate outside of this class
	private init() {}
	
	// Convert Date data to String
	static func formatted(date: Date) -> String {
		dateFormatter.dateFormat = "yyyy.MM.dd"
		dateFormatter.locale = Calendar.current.locale
		return dateFormatter.string(from: date)
	}
	
	// Get current time for debugging
	static func localTime(date: Date) -> String {
		let calendar = Calendar.current
		let year = calendar.component(.year, from: date)
		let month = calendar.component(.month, from: date)
		let day = calendar.component(.day, from: date)
		let hour = calendar.component(.hour, from: date)
		let minutes = calendar.component(.minute, from: date)
		return "\(year).\(month).\(day) \(hour):\(minutes)"
	}
}
