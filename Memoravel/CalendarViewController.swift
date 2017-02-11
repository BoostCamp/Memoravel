//
//  CalendarViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/9/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import FSCalendar

protocol CalendarViewControllerDelegate {
	func completeToSelectingDate(date: Date)
}

class CalendarViewController: UIViewController {
	
	var delegate: CalendarViewControllerDelegate?
	var selectedDate: Date?
	var senderTag: Int?
	var startDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Settings for Navigation title
		if let tag = senderTag {
			switch tag {
			case 1:
				navigationItem.title = "Choose Start Date"
				
			case 2:
				navigationItem.title = "Choose End Date"
				
			default:
				return
			}
		}
    }
	
	@IBAction func comfirmDate(_ sender: Any) {
		if let delegate = self.delegate, let date = self.selectedDate {
			delegate.completeToSelectingDate(date: date)
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	@IBAction func cancelChoosing(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Implement methods of FSCalendarDataSource and FSCalendarDelegate

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
	
	func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
		selectedDate = date
	}
	
	func minimumDate(for calendar: FSCalendar) -> Date {
		if let startDate = self.startDate {
			return startDate
		}
		
		return Date(timeIntervalSince1970: 0)
	}
	
	// Set maximum date to current date, so user could not choose future dates
	func maximumDate(for calendar: FSCalendar) -> Date {
		return calendar.today ?? Date()
	}
}
