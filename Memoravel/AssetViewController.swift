//
//  AssetViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import Photos

// TODO: Get assets from Photos asynchronously?

class AssetViewController: UIViewController {
	
	var startDate: Date!
	var endDate: Date!
	
	var dateHeader = [Date]()
	var selectedPhotos = [PHFetchResult<PHAsset>]()
	var totalNumOfAssets: Int = 0
	
	@IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = JourneyDate.formatted(date: startDate) + " - " + JourneyDate.formatted(date: endDate)
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		var date: Date = startDate
		let fetchOptions = PHFetchOptions()
		
		while date <= endDate {
			// Save headers of collection view
			dateHeader.append(date)
			
			// Get image assets taken at selected date
			let nextDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
			fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", date as NSDate, nextDate as NSDate)
			let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: fetchOptions)
			self.totalNumOfAssets += fetchResult.count
			selectedPhotos.append(fetchResult)
			
			date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
		}
		
		if totalNumOfAssets == 0 { collectionView.isHidden = true }
    }
}

// MARK: - Implement methods of UICollectionViewDelegate and UICollectionViewDataSource

extension AssetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.dateHeader.count
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
		
		if let headerView = reusableView as? AssetHeaderCollectionReusableView {
			headerView.headerLabel.text = JourneyDate.formatted(date: self.dateHeader[indexPath.section])
		}
		
		return reusableView
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.selectedPhotos[section].count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath)
		
		if let assetCell = cell as? AssetCollectionViewCell {
			let assets = self.selectedPhotos[indexPath.section]
			let asset: PHAsset = assets[indexPath.row]
			
			PHImageManager.default().requestImage(for: asset, targetSize: assetCell.assetImageView.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
				assetCell.assetImageView.image = image
			})
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		performSegue(withIdentifier: "ShowDetailView", sender: self.selectedPhotos[indexPath.section][indexPath.row])
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? DetailViewController, let asset = sender as? PHAsset {
			controller.asset = asset
		}
	}
}

// MARK: - Implement methods of UICollectionViewDelegateFlowLayout

extension AssetViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width: CGFloat = collectionView.frame.width / 3 - 1
		return CGSize(width: width, height: width)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 1.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 1.0
	}
}
