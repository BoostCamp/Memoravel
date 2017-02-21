//
//  MasterViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

	var journeyController: JourneyController!
	var selectedRow: IndexPath?
	
	@IBOutlet weak var initialView: UIView!
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Subscribe Notification when the user chooses an image as a thumbnail
		self.subscribeToSetAsThumbnail()
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		self.journeyController = JourneyController.sharedInstance()
		if journeyController.count > 0 {
			self.initialView.isHidden = true
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

	// MARK: - Action method when user wants to make a new journey
	
	@IBAction func createJourney(_ sender: Any) {
		if let nextController = self.storyboard?.instantiateViewController(withIdentifier: "CreateJourneyViewController") as? CreateJourneyViewController {
			nextController.delegate = self
			
			let navController = UINavigationController(rootViewController: nextController)
			navController.navigationBar.barTintColor = UIColor.journeyMainColor
			navController.navigationBar.tintColor = UIColor.journeyLightColor
			navController.navigationBar.barStyle = .black
			navController.navigationBar.isTranslucent = false
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
		
			let titleTextAttributes = NSAttributedString(string: journey.title, attributes: [
				NSStrokeColorAttributeName : UIColor.black,
				NSForegroundColorAttributeName : UIColor.journeyLightColor,
				NSFontAttributeName : UIFont(name: "AppleSDGothicNeo-Bold", size: 40)!,
				NSStrokeWidthAttributeName : -3.0
			])
			
			let dates: String = JourneyDate.formatted(date: journey.startDate) + " - " + JourneyDate.formatted(date: journey.endDate)
			
			let dateTextAttributes = NSAttributedString(string: dates, attributes: [
				NSStrokeColorAttributeName : UIColor.black,
				NSForegroundColorAttributeName : UIColor.journeyLightColor,
				NSFontAttributeName : UIFont(name: "AppleSDGothicNeo-Regular", size: 25)!,
				NSStrokeWidthAttributeName : -3.0
			])
			
			masterCell.journeyTitle.attributedText = titleTextAttributes
			masterCell.journeyDate.attributedText = dateTextAttributes
			masterCell.thumbnailImageView.image = journey.thumbnailImage
			masterCell.tintColor = UIColor.journeyLightColor
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			print("cell #\(indexPath.row) is about to delete!")
			confirmDelete(indexPath: indexPath)
		}
	}
	
	func confirmDelete(indexPath: IndexPath) {
		let alertController = UIAlertController(title: "Delete Journey", message: "Are you sure you want to delete this journey?", preferredStyle: .actionSheet)
		
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
			self.journeyController.removeJourney(at: indexPath.row)
			self.tableView.beginUpdates()
			self.tableView.deleteRows(at: [indexPath], with: .fade)
			self.tableView.endUpdates()
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			self.tableView.setEditing(false, animated: true)
		}
		
		alertController.addAction(deleteAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Save the information of selected row
		self.selectedRow = indexPath
		
		performSegue(withIdentifier: "ShowScheduleView", sender: journeyController.getJourney(at: indexPath.row))
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let journey: Journey = sender as? Journey, let controller = segue.destination as? ScheduleViewController {
			controller.journey = journey
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

// MARK: - Implement method of DetailViewControllerDelegate

extension MasterViewController {
	
	func subscribeToSetAsThumbnail() {
		NotificationCenter.default.addObserver(self, selector: #selector(didSelectAsThumbnail), name: .beAboutToThumbnail, object: nil)
	}
	
	func didSelectAsThumbnail(_ notification: Notification) {
		if let image: UIImage = notification.object as? UIImage {
			print("I'VE GOT AN IMAGE FROM NOTIFICATION SENDER ;-]")
			
			if let indexPath = self.selectedRow {
				let journey: Journey = self.journeyController.getJourney(at: indexPath.row)
				journey.thumbnailImage = image
				self.tableView.reloadData()
			
			} else {
				print("THERE'S NO INDEX PATH THAT MASTER VIEW CONTROLLER HAS...")
			}
		
		} else {
			print("I DIDN'T GOT AN IMAGE FROM NOTIFICATION SENDER...")
		}
	}
}
