//
//  ScheduleViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {

	let journeyController: JourneyController = JourneyController.shared
	var indexOfJourney: Int!
	var journey: Journey!
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and dataSource of UITableView
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		// Assign journey instance
		self.journey = journeyController.getJourney(at: indexOfJourney)
		
		// Set navigation title
		self.navigationItem.title = self.journey.title
    }
}

// MARK: - Implement methods of UITableViewDataSource, UITableViewDelegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.journey.mainSchedule.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath)
		
		if let scheduleCell = cell as? SchedulesTableViewCell {
			let mainSchedule = journey.mainSchedule[indexPath.row]
			let startDate: String = JourneyDate.formatted(date: mainSchedule.schedule.startDate)
			let endDate: String = JourneyDate.formatted(date: mainSchedule.schedule.endDate)
			
			scheduleCell.dateLabel.text = startDate + " - " + endDate
			scheduleCell.locationLabel.text = JourneyAddress.parseDetailAddress(mainSchedule.schedule.location)
			scheduleCell.tapAction = { (scheduleCell) in
				let dates: (Date, Date) = (mainSchedule.schedule.startDate, mainSchedule.schedule.endDate)
				self.performSegue(withIdentifier: "ShowAssetView", sender: dates)
			}
		}
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? AssetViewController, let dates: (startDate: Date, endDate: Date) = sender as? (Date, Date) {
			controller.startDate = dates.startDate
			controller.endDate = dates.endDate
		}
	}
}
