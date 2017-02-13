//
//  MasterViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
	
	let journeyController: JourneyController = JourneyController.shared

	
	@IBOutlet weak var initialView: UIView!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		// Settings for rightBarButton
		let addButton = UIButton(type: .custom)
		addButton.setImage(#imageLiteral(resourceName: "add_white"), for: .normal)
		addButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		addButton.addTarget(self, action: #selector(createJourney), for: .touchUpInside)
		addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		let addBarButton = UIBarButtonItem(customView: addButton)
		navigationItem.rightBarButtonItem = addBarButton
	}

	// MARK: - Action method when user wants to make a new journey
	
	func createJourney() {
		if let nextController = self.storyboard?.instantiateViewController(withIdentifier: "CreateJourneyViewController") as? CreateJourneyViewController {
			nextController.delegate = self
			
			let navController = UINavigationController(rootViewController: nextController)
			navController.navigationBar.barTintColor = UIColor.journeyMainColor
			navController.navigationBar.tintColor = UIColor.journeyLightColor
			navController.navigationBar.barStyle = .black
			self.present(navController, animated: true, completion: nil)
		}
	}
}

// MARK: - Implement methods of UITableViewDelegate and UITableViewDataSource

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return journeyController.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "JourneyCell", for: indexPath)
		
		if let masterCell = cell as? MasterTableViewCell {
			let journey: Journey = journeyController.getJourney(at: indexPath.row)
			masterCell.journeyTitle.text = journey.title
			masterCell.journeyDate.text = JourneyDate.formatted(date: journey.startDate) + " - " + JourneyDate.formatted(date: journey.endDate)
			masterCell.thumbnailImageView.image = journey.thumbnailImage
			masterCell.tintColor = UIColor.journeyLightColor
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "ToScheduleViewController", sender: indexPath.row)
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let index: Int = sender! is Int ? sender as! Int : 0
		if let controller = segue.destination as? ScheduleViewController {			
			controller.indexOfJourney = index
		}
	}

}

// MARK: - Implement method of CreateJourneyViewControllerDelegate
// NOTE: This delegate is for check whether there's information or not

extension MasterViewController: CreateJourneyViewControllerDelegate {
	
	func finishCreatingNewJourney() {
		tableView.reloadData()
		
		if journeyController.count > 0 {
			self.initialView.isHidden = true
		}
	}
}

