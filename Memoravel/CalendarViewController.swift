//
//  CalendarViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/9/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import FSCalendar
import Photos

protocol CalendarViewControllerDelegate {
	func completeToSelectingDate(date: Date)
}

class CalendarViewController: UIViewController {
	
	var delegate: CalendarViewControllerDelegate?
	var selectedDate: Date!
	var senderTag: Int?
	var startDate: Date?
	
	var selectedPhotos: PHFetchResult<PHAsset>?
	
	@IBOutlet weak var calendar: FSCalendar!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var informationLabel: UILabel!
	
	@IBOutlet weak var addView: UIView!
	@IBOutlet weak var addButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Settings for Navigation title
		if let tag = senderTag {
			switch tag {
			case 1:
				navigationItem.title = "Select a Start Date"
				self.informationLabel.text = "Choose the first image of the schedule"
				
			case 2:
				navigationItem.title = "Select an End Date"
				self.informationLabel.text = "Choose the last image of the schedule"
				
			default:
				return
			}
		}
		
		if let date = self.startDate {
			self.calendar.currentPage = date
		}
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		// Settings for Add view
		self.addView.isHidden = true
		self.addButton.setImage(#imageLiteral(resourceName: "check_light"), for: .highlighted)
    }
	
	@IBAction func doneChoosing(_ sender: Any) {
		if let delegate = self.delegate {
			delegate.completeToSelectingDate(date: self.selectedDate)
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
		self.selectedDate = date
		let nextDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: date)!

		print(JourneyDate.localTime(date: date))
		print(JourneyDate.localTime(date: nextDate))
		
		// Get image assets taken at selected date
		let fetchOptions = PHFetchOptions()
		fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", self.selectedDate as NSDate, nextDate as NSDate)
		fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
		self.selectedPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)

		self.collectionView.reloadData()
		
		if (self.selectedPhotos?.count)! == 0 {
			self.addView.isHidden = false
		
		} else {
			self.addView.isHidden = true
		}
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

// MARK: - Implement methods of UICollectionViewDelegate and UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
		
		if let imageCell = cell as? CalendarCollectionViewCell {
			let asset = (self.selectedPhotos?[indexPath.row])!
			PHImageManager.default().requestImage(for: asset, targetSize: imageCell.assetImageView.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
				imageCell.assetImageView.image = image
			})
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.selectedPhotos?.count ?? 0
	}
	
	// If the user clicks image cell, find out the creation date of the asset and send it
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let asset = (self.selectedPhotos?[indexPath.row])!
		let date: Date = asset.creationDate!
		
		print("selected date from asset: \(date)")
		
		if let delegate = self.delegate {
			delegate.completeToSelectingDate(date: date)
			self.dismiss(animated: true, completion: nil)
		}
	}
}
