//
//  CreateJourneyViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import MapKit

class CreateJourneyViewController: UIViewController {
	
	var numOfMainSchedule: Int = 1
	var mainSchedule = [MainSchedule]()
	var activeLocationButton: UIButton?

	@IBOutlet weak var journeyTitle: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		journeyTitle.delegate = self
    }
	
	@IBAction func searchLocation(_ sender: UIButton) {
		if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
			self.activeLocationButton = sender
			controller.delegate = self
			
			let navController = UINavigationController(rootViewController: controller)
			navController.navigationBar.barTintColor = UIColor.journeyMainColor
			navController.navigationBar.tintColor = UIColor.journeyLightColor
			navController.navigationBar.barStyle = .black
			self.present(navController, animated: true, completion: nil)
		}
	}
	
	// Add another main schedule
	@IBAction func addMainSchedule(_ sender: UIButton) {
		numOfMainSchedule += 1
		sender.isHidden = true
		// TODO: Add main schedule data to the array
		tableView.reloadData()
	}

	// MARK: - Complete creation of Journey data or cancel it
	
	@IBAction func doneCreation(_ sender: Any) {
		// Check all the information is presented.
	}
	
	
	@IBAction func cancelCreating(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

// MARK: - Implement methods of UITableViewDataSource and UITableViewDelegate

extension CreateJourneyViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numOfMainSchedule
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MainScheduleCell", for: indexPath)
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
		let location: String = JourneyAddress.parseAddress(placemark)
		self.activeLocationButton?.setTitle(location, for: .normal)
	}
}
