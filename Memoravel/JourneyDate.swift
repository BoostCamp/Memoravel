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
		dateFormatter.dateFormat = "yy.MM.dd"
		return dateFormatter.string(from: date)
	}
}
