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

// TODO: Create navigation controller to navigate from start date view to end date view sequentially
// TODO: Show dialogue when user choose wrong date

protocol CalendarViewControllerDelegate {
	func completeToSelectingDate(date: Date)
}

class CalendarViewController: UIViewController {
	
	var delegate: CalendarViewControllerDelegate?
	var selectedDate: Date?
	var senderTag: Int?
	var startDate: Date?
	
	var selectedPhotos: PHFetchResult<PHAsset>?
	
	@IBOutlet weak var calendar: FSCalendar!
	@IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
//		self.calendar.select(self.selectedDate, scrollToDate: true)
		
		// Settings for Navigation title
		if let tag = senderTag {
			switch tag {
			case 1:
				navigationItem.title = "Select a Start Date"
				
			case 2:
				navigationItem.title = "Select an End Date"
				
			default:
				return
			}
		}
		
		if let date = self.startDate {
			self.calendar.currentPage = date
		}
		
		collectionView.delegate = self
		collectionView.dataSource = self
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
		let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
		
		// Get image assets taken at selected date
		let fetchOptions = PHFetchOptions()
		fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", date as NSDate, (nextDate ?? date) as NSDate)
		selectedPhotos = PHAsset.fetchAssets(with: fetchOptions)
		self.collectionView.reloadData()
		
		// TODO: What does this code mean?
//		self.collectionView.collectionViewLayout.invalidateLayout()
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
}
