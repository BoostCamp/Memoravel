//
//  MasterViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
	
	let journeyController: JourneyController = JourneyController.shared

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.separatorStyle = .none
		
		// Settings for rightBarButton
		let addButton = UIButton(type: .custom)
		addButton.setImage(#imageLiteral(resourceName: "add_white"), for: .normal)
		addButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		addButton.addTarget(self, action: #selector(createJourney), for: .touchUpInside)
		addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		let addBarButton = UIBarButtonItem(customView: addButton)
		navigationItem.rightBarButtonItem = addBarButton
	}
	
	// MARK: - Implement methods of UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return journeyController.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "JourneyCell", for: indexPath)
		
		if let masterCell = cell as? MasterTableViewCell {
			let journey: Journey = journeyController.getJourney(at: indexPath.row)
			masterCell.titleLabel.text = journey.title
			masterCell.dateLabel.text = JourneyDate.formatted(date: journey.startDate) + " - " + JourneyDate.formatted(date: journey.endDate)
			masterCell.thumbnailImageView.image = journey.thumbnailImage
			masterCell.tintColor = UIColor.journeyLightColor
		}
		
		return cell
	}
	
	// MARK: - Implement method of UITableViewDelegate
	
	// TODO: 테이블 셀이 눌렸을 때, ScheduleViewController 로 넘어가게 만들기

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

extension MasterViewController: CreateJourneyViewControllerDelegate {
	
	func finishCreatingNewJourney() {
		tableView.reloadData()
	}
}

