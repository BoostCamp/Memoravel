//
//  DateExtension.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/18/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation

extension Date {
	
	static func getDateFromString(_ dateString: String) -> Date {
		let dateStringFormatter = DateFormatter()
		dateStringFormatter.dateFormat = "yyyy.MM.dd"
		dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
		let date = dateStringFormatter.date(from: dateString) ?? Date()
		
		return Date(timeInterval: 0, since: date)
	}
}

// Change date and time
extension Date {
	
	struct Calendar {
		
		static let utc: NSCalendar  = {
			var calendar = NSCalendar.current
			calendar.timeZone = TimeZone(abbreviation: "UTC")!
			return calendar as NSCalendar
		}()
	}
	
	var startOfDayAtUTC: Date {
		return Calendar.utc.startOfDay(for: self)
	}
}
