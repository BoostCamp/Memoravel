//
//  CreateJourneyViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit

// FIXME: Induce users to add main schedules sequentially according to the date


protocol CreateJourneyViewControllerDelegate {
	func finishCreatingNewJourney()
}

class CreateJourneyViewController: UIViewController {
	
	// Data controller handling Journeys
	let journeyController = JourneyController.shared
	
	var delegate: CreateJourneyViewControllerDelegate?
	
	var mainSchedule = [MainSchedule]()
	var activeButton: UIButton?
	
	var startDateButton: UIButton?
	var endDateButton: UIButton?
	var addScheduleButton: UIButton?
	
	var selectedLocation: MKPlacemark?
	var selectedStartDate: Date?
	var selectedEndDate: Date?

	@IBOutlet weak var journeyTitle: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		journeyTitle.delegate = self
		navigationItem.rightBarButtonItem?.isEnabled = false
    }
	
	// Search location from default map
	@IBAction func searchLocation(_ sender: UIButton) {
		if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
			self.activeButton = sender
			controller.delegate = self
			
			let navController = UINavigationController(rootViewController: controller)
			navController.navigationBar.barTintColor = UIColor.journeyMainColor
			navController.navigationBar.tintColor = UIColor.journeyLightColor
			navController.navigationBar.barStyle = .black
			self.present(navController, animated: true, completion: nil)
		}
	}
	
	// Choose date from calendar
	@IBAction func chooseDate(_ sender: UIButton) {
		if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
			self.activeButton = sender
			controller.delegate = self
			controller.senderTag = sender.tag
			
			if sender.tag == 2 {
				// If user clicks end date button
				controller.startDate = self.selectedStartDate
			}
			
			let navController = UINavigationController(rootViewController: controller)
			navController.navigationBar.barTintColor = UIColor.journeyMainColor
			navController.navigationBar.tintColor = UIColor.journeyLightColor
			navController.navigationBar.barStyle = .black
			
			self.present(navController, animated: true, completion: nil)
		}
	}

	// MARK: - Complete creation of Journey data or cancel it
	
	@IBAction func doneCreation(_ sender: Any) {
		appendNewMainSchedule()
		
		if self.mainSchedule.count > 0, let delegate = self.delegate {
			// If there's main schedule
			let journeyStartDate: Date = (self.mainSchedule.first?.schedule.startDate)!
			let journeyEndDate: Date = (self.mainSchedule.last?.schedule.endDate)!
			let newJourney = Journey(title: journeyTitle.text ?? "Notitle", startDate: journeyStartDate, endDate: journeyEndDate, mainSchedule: mainSchedule, thumbnailImage: nil)
			journeyController.addJourney(newJourney)
			
			delegate.finishCreatingNewJourney()
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	@IBAction func cancelCreating(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

// MARK: - Implement methods of UITableViewDataSource and UITableViewDelegate

extension CreateJourneyViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mainSchedule.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CreateJourneyTableViewCell", for: indexPath)
		
		if indexPath.row == mainSchedule.count, let mainScheduleCell = cell as? CreateJourneyTableViewCell {
			self.startDateButton = mainScheduleCell.startDateButton
			self.endDateButton = mainScheduleCell.endDateButton
		
			self.startDateButton?.isEnabled = false
			self.endDateButton?.isEnabled = false
		}
		
		return cell
	}
}

// MARK: - Implement method of UITextFieldDelegate

extension CreateJourneyViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

extension CreateJourneyViewController: MapViewControllerDelegate {
	
	func didSelectedLocation(_ placemark: MKPlacemark) {
		self.selectedLocation = placemark
		let location: String = JourneyAddress.parseAddress(placemark)
		self.activeButton?.setTitle(location, for: .normal)
		self.startDateButton?.isEnabled = true
	}
}

// MARK: - Implement method of CalendarViewControllerDelegate

extension CreateJourneyViewController: CalendarViewControllerDelegate {
	
	func completeToSelectingDate(date: Date) {
		if let tag = self.activeButton?.tag {
			switch tag {
			case 1:
				// Start date button
				self.selectedStartDate = date
				self.endDateButton?.isEnabled = true
				
			case 2:
				// End date button
				self.selectedEndDate = date
				appendNewMainSchedule()
				self.tableView.reloadData()
				self.navigationItem.rightBarButtonItem?.isEnabled = true
				
			default:
				return
			}
		}
		
		let selectedDate: String = JourneyDate.formatted(date: date)
		self.activeButton?.setTitle(selectedDate, for: .normal)
	}
}

// MARK: - Create a method to add main schedule to the array

extension CreateJourneyViewController {
	
	func appendNewMainSchedule() {
		// Add main schedule to the array
		if let location = selectedLocation, let startDate = selectedStartDate, let endDate = selectedEndDate {
			let newSchedule = Schedule(location: location, startDate: startDate, endDate: endDate)
			self.mainSchedule.append(MainSchedule(schedule: newSchedule, subSchedule: nil))
			
			self.selectedLocation = nil
			self.selectedStartDate = nil
			self.selectedEndDate = nil
		}
	}
}
