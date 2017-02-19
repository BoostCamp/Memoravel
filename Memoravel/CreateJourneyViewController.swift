//
//  CreateJourneyViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit

protocol CreateJourneyViewControllerDelegate {
	func finishCreatingNewJourney()
}

class CreateJourneyViewController: UIViewController {
	
	// Data controller handling Journeys
	let journeyController = JourneyController.sharedInstance()
	
	var delegate: CreateJourneyViewControllerDelegate?
	
	var schedules = [Schedule]()
	var activeButton: UIButton?
	
	var currentLocationButton: UIButton?
	var currentStartDateButton: UIButton?
	var currentEndDateButton: UIButton?
	var addScheduleButton: UIButton?
	
	var selectedLocation: MKPlacemark?
	var selectedStartDate: Date?
	var selectedEndDate: Date?
	var lastSelectedDate: Date?
	
	// Check whether the cell is about to delete
	var isEditingCell: Bool = false

	@IBOutlet weak var journeyTitleTextField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		journeyTitleTextField.delegate = self
		navigationItem.rightBarButtonItem?.isEnabled = false
    }
	
	// Search location from default map
	@IBAction func searchLocation(_ sender: UIButton) {
		if self.isEditingCell { return }
		
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
		if self.isEditingCell { return }
		
		if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
			controller.delegate = self
			controller.senderTag = sender.tag
			self.activeButton = sender
			
			switch sender.tag {
			// If the user clicks start date button
			case 1:
				if let lastEndDate = self.lastSelectedDate {
					controller.startDate = lastEndDate
				}
				
			case 2:
				// If the user clicks end date button
				controller.startDate = self.selectedStartDate
				
			default:
				return
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
		if let location = self.selectedLocation, let startDate = self.selectedStartDate, let endDate = self.selectedEndDate {
			let emptyAssets = [Date : [TravelAsset]]()
			self.schedules.append(Schedule(location: location, startDate: startDate, endDate: endDate, assets: emptyAssets))
		}
		
		if self.schedules.count > 0, let delegate = self.delegate {
			// If there's a schedule
			let journeyStartDate: Date = (self.schedules.first?.startDate)!
			let journeyEndDate: Date = (self.schedules.last?.endDate)!
			
			var journeyTitle: String = self.journeyTitleTextField.text ?? ""
			if journeyTitle == "" { journeyTitle = "No Title" }
			
			let newJourney = Journey(title: journeyTitle, startDate: journeyStartDate, endDate: journeyEndDate, schedules: self.schedules)
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
		return self.schedules.count + 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let scheduleCell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! CreateScheduleCell
		
		// Cell for "add new schedule"
		if indexPath.row == self.schedules.count + 1 {
			scheduleCell.addNewCellAction = self.appendNewMainSchedule
			scheduleCell.initialView.isHidden = false
			self.addScheduleButton = scheduleCell.addButton
			self.addScheduleButton?.isEnabled = (self.selectedEndDate != nil)
		
			return scheduleCell
		}
		
		scheduleCell.initialView.isHidden = true
		
		// Current editing row
		if indexPath.row == self.schedules.count {
			var location: String = "Select a Location"
			if let placemark = self.selectedLocation { location = JourneyAddress.parseBriefAddress(placemark) }
			scheduleCell.locationButton.setTitle(location, for: .normal)
			
			var startDate: String = "Choose a Start Date"
			if let date = self.selectedStartDate { startDate = JourneyDate.formatted(date: date) }
			scheduleCell.startDateButton.setTitle(startDate, for: .normal)
			
			var endDate: String = "Choose an End Date"
			if let date = self.selectedEndDate { endDate = JourneyDate.formatted(date: date) }
			scheduleCell.endDateButton.setTitle(endDate, for: .normal)
			
			self.currentLocationButton = scheduleCell.locationButton
			self.currentStartDateButton = scheduleCell.startDateButton
			self.currentEndDateButton = scheduleCell.endDateButton
			
			self.currentStartDateButton?.isEnabled = (self.selectedLocation != nil)
			self.currentEndDateButton?.isEnabled = (self.selectedStartDate != nil)

		
		// Edited rows before
		} else if indexPath.row < self.schedules.count {
			let location: String = JourneyAddress.parseBriefAddress(self.schedules[indexPath.row].location)
			let startDate: String = JourneyDate.formatted(date: self.schedules[indexPath.row].startDate)
			let endDate: String = JourneyDate.formatted(date: self.schedules[indexPath.row].endDate)
			
			scheduleCell.locationButton.setTitle(location, for: .normal)
			scheduleCell.startDateButton.setTitle(startDate, for: .normal)
			scheduleCell.endDateButton.setTitle(endDate, for: .normal)
			
			scheduleCell.locationButton.isEnabled = true
			scheduleCell.startDateButton.isEnabled = true
			scheduleCell.endDateButton.isEnabled = true
		}
		
		return scheduleCell
	}
	
	// Disable to edit cell if the cell does not have data
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if indexPath.row < self.schedules.count { return true }
		return false
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			print("cell #\(indexPath.row) is about to delete!")
			confirmDelete(indexPath: indexPath)
		}
	}
	
	func confirmDelete(indexPath: IndexPath) {
		let alertController = UIAlertController(title: "Delete schedule", message: "Are you sure you want to delete this schedule?", preferredStyle: .actionSheet)
		
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
			// If the cell which is going to be deleted is first row
			if indexPath.row == 0 {
				self.selectedEndDate = nil
			
			} else if (indexPath.row + 1) == self.schedules.count {
				self.selectedEndDate = self.schedules[indexPath.row - 1].endDate
			}
			
			self.schedules.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			self.tableView.setEditing(false, animated: true)
		}
		
		alertController.addAction(deleteAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		self.isEditingCell = true
	}
	
	func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		self.isEditingCell = false
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
		// Change current selected button title
//		self.activeButton?.setTitle(JourneyAddress.parseBriefAddress(placemark), for: .normal)
		
		let contentView = self.activeButton?.superview
		if let currentCell = contentView?.superview as? CreateScheduleCell {
			if let startDate = currentCell.startDateButton.title(for: .normal), let endDate = currentCell.endDateButton.title(for: .normal), (startDate != "Choose a Start Date" && endDate != "Choose an End Date") {
				// If the user wants to change the location, update schedules cell
				let indexPath = self.tableView.indexPath(for: currentCell)!
				self.schedules[indexPath.row].location = placemark
				print("location has been changed!")
			
			} else {
				self.selectedLocation = placemark
			}
		}
		
		self.tableView.reloadData()
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
				self.activeButton?.setTitle(JourneyDate.formatted(date: date), for: .normal)
				self.currentEndDateButton?.isEnabled = true
				
			case 2:
				// End date button
				self.selectedEndDate = date
				self.lastSelectedDate = date
				self.activeButton?.setTitle(JourneyDate.formatted(date: date), for: .normal)
				self.addScheduleButton?.isEnabled = true
				self.navigationItem.rightBarButtonItem?.isEnabled = true
				
			default:
				return
			}
		}
		
		self.tableView.reloadData()
	}
}

// MARK: - Create a method to add a new Schedule instance to the array

extension CreateJourneyViewController {
	
	func appendNewMainSchedule() {
		if let location = self.selectedLocation, let startDate = self.selectedStartDate, let endDate = self.selectedEndDate {
			
			print("ADD NEW CELL :-]")
			
			let emptyAssets = [Date : [TravelAsset]]()
			self.schedules.append(Schedule(location: location, startDate: startDate, endDate: endDate, assets: emptyAssets))
			
			self.selectedLocation = nil
			self.selectedStartDate = nil
			self.selectedEndDate = nil
			
			if !((navigationItem.rightBarButtonItem?.isEnabled)!) { navigationItem.rightBarButtonItem?.isEnabled = true }
			
			self.tableView.reloadData()
		
		} else {
			print("USER TRIES TO ADD NEW CELL, BUT ALL THE INFORMATION WAS NOT FILLED :-[")
		}
	}
}
