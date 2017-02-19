//
//  AssetViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import Photos

class AssetViewController: UIViewController {

	var schedule: Schedule!
	
	var startDate: Date!
	var endDate: Date!
	var dateHeader = [Date]()
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	// MARK: - Properties for normal mode
	
	// When the user chooses to see only like assets
	var isShowingLikeAssets: Bool = false
	var likeDateHeader = [Date]()
	var likeDateHeaderSet = Set<Date>()
	var likeTravelAssetsDict = [Date : [TravelAsset]]()
	
	// When the user chooses to see all assets
	@IBOutlet weak var showAllImagesButton: UIBarButtonItem!
	@IBOutlet weak var showLikeImagesButton: UIBarButtonItem!
	
	// MARK: - Properties for edit mode
	
	var isEditMode: Bool = false
	var selectedAssets = Set<IndexPath>()
	
	@IBOutlet weak var informationView: UIView!
	@IBOutlet weak var informationLabel: UILabel!
	@IBOutlet weak var editToolBar: UIToolbar!
	@IBOutlet weak var deleteImagesButton: UIBarButtonItem!
	@IBOutlet weak var setLikeImagesButton: UIBarButtonItem!
	
	// MARK: - Image views which tells to the user that there's no asset
 
	@IBOutlet weak var noImageView: UIView!
	@IBOutlet weak var noLikeImageView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		self.startDate = self.schedule.startDate
		self.endDate = self.schedule.endDate
		
		if let locality = JourneyAddress.parseTitleAddress(self.schedule.location) {
			navigationItem.title = locality
		
		} else {
			navigationItem.title = JourneyDate.formatted(date: startDate) + " - " + JourneyDate.formatted(date: endDate)
		}
		
		// Assign DateHeader at first
		self.initializeDateHeader()
		
		// Add right bar button on the right side of the navigation bar
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(showEditMode))
		
		// Hide tool bar used in edit mode
		self.editToolBar.isHidden = true
		
		// Set tint color to the tool bar buttons
		self.showAllImagesButton.tintColor = UIColor.journeyMainColor
		self.showLikeImagesButton.tintColor = UIColor.lightGray
		
		// Connet action methods to the bar button items in normal tool bar
		self.showAllImagesButton.action = #selector(showAllImages)
		self.showLikeImagesButton.action = #selector(showLikeImages)
		
		// Disable selecting bar buttons in edit tool bar in initial state
		self.deleteImagesButton.isEnabled = false
		self.setLikeImagesButton.isEnabled = false
		
		// Connect action methods to the bar button items in edit tool bar
		self.deleteImagesButton.action = #selector(deleteImage)
		self.setLikeImagesButton.action = #selector(setLikeImage)
		
		// If there's no asset on that schedule
		if self.dateHeader.count == 0 {
			self.noImageView.isHidden = false
			
		} else {
			self.noImageView.isHidden = true
		}
		
		// Hide No Like Image View at first
		self.noLikeImageView.isHidden = true
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// When the user gets back from detail view
		if isShowingLikeAssets {
			self.likeDateHeaderSet = []
			self.likeDateHeader = []
			self.likeTravelAssetsDict = [:]
			showLikeImages()
		}
	}
	
	// MARK: - Settings for edit mode
	func showEditMode() {
		self.isEditMode = true
		self.editToolBar.isHidden = false
		
		// Show information view
		self.showInformationView()
		
		if isShowingLikeAssets {
			self.setLikeImagesButton.image = #imageLiteral(resourceName: "set_dislike")
		
		} else {
			self.setLikeImagesButton.image = #imageLiteral(resourceName: "dislike_bold")
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(showNormalMode))
		
		// Allow multiple selection
		self.collectionView.allowsMultipleSelection = true
		
		// Disable delete and like/dislike button at first
		self.deleteImagesButton.isEnabled = false
		self.setLikeImagesButton.isEnabled = false
	}
	
	func selectAsset(_ indexPath: IndexPath) {
		// Show information view
		self.showInformationView()
		
		self.selectedAssets.insert(indexPath)
//		self.lastInsertedIndexPath = indexPath
		self.deleteImagesButton.isEnabled = true
		self.setLikeImagesButton.isEnabled = true
	}
	
	func deselectAsset(_ indexPath: IndexPath) {
		self.selectedAssets.remove(indexPath)
		
		if self.selectedAssets.count == 0 {
			// Hide information view
			self.hideInformationView()
			
			self.deleteImagesButton.isEnabled = false
			self.setLikeImagesButton.isEnabled = false
		}
	}
	
	// Initiate properties when convert to normal mode
	func deselectAllAssets() {
		for indexPath in selectedAssets {
			self.collectionView.deselectItem(at: indexPath, animated: false)
			if let assetCell = self.collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell {
				assetCell.effectView.isHidden = true
			}
		}
		
		self.selectedAssets = []
		
		// Hide information view
		self.hideInformationView()
	}
	
	func deleteImage() {
		let title: String
		let message: String
		
		if selectedAssets.count == 1 {
			title = "Delete an Image"
			message = "Are you sure you want to delete a selected image?"
			
		} else {
			title = "Delete Images"
			message = "Are you sure you want to delete selected images?"
		}
		
		let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
			
			if self.isShowingLikeAssets {
				for indexPath in self.selectedAssets {
					let date: Date = self.likeDateHeader[indexPath.section]
					let asset: TravelAsset = self.likeTravelAssetsDict[date]![indexPath.row]
					let count: Int = self.schedule.assetsDict[date]!.count
					
					for index in 0..<count {
						if asset == (self.schedule.assetsDict[date]!)[index] {
							self.schedule.assetsDict[date]!.remove(at: index)
							break
						}
					}
				}
				
			} else {
				// Create cached descending index path to avoid invalid index error
//				let descendingIndexPath: [IndexPath] = self.selectedAssets.reversed()
				let descendingIndexPath: [IndexPath] = self.selectedAssets.sorted(by: {
					if $0.section > $1.section {
						return true
					
					} else if $0.section == $1.section {
						return $0.row > $1.row
					
					} else {
						return false
					}
				})
				
				for indexPath in descendingIndexPath {
					let date: Date = self.dateHeader[indexPath.section]
					self.schedule.assetsDict[date]?.remove(at: indexPath.row)
				}
			}
			
			self.deselectAllAssets()
			
			if self.isShowingLikeAssets {
				self.showLikeImages()
			
			} else {
				self.showAllImages()
			}
			
			self.showNormalMode()
			
			self.dismiss(animated: true, completion: nil)
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			self.deselectAllAssets()
			if self.isShowingLikeAssets { self.showLikeImages() }
			self.showNormalMode()
		}
		
		controller.addAction(deleteAction)
		controller.addAction(cancelAction)
		
		self.present(controller, animated: true, completion: nil)
	}
	
	func setLikeImage() {
		// If the view shows only like assets and the user clicks dislike button, change like status to false
		if self.isShowingLikeAssets {
			print("\(self.selectedAssets.count) ITEMS WILL BE UNLIKED ;-[")
			for indexPath in selectedAssets {
				let date: Date = likeDateHeader[indexPath.section]
				let asset: TravelAsset = (likeTravelAssetsDict[date])![indexPath.row]
				asset.isLike = false
			}
			
			self.deselectAllAssets()
			self.showLikeImages()
			
		// If the view shows all assets and the user clicks like button, change like status to true
		} else {
			print("\(self.selectedAssets.count) ITEMS WILL BE LIKED ;-]")
			for indexPath in self.selectedAssets {
				let date: Date = self.dateHeader[indexPath.section]
				let asset: TravelAsset = (self.schedule.assetsDict[date])![indexPath.row]
				asset.isLike = true
			}
		}
		
		self.showNormalMode()
	}
	
	// MARK: - Settings for normal mode
	
	func showNormalMode() {
		self.isEditMode = false
		self.editToolBar.isHidden = true

		// Hide information view
		self.hideInformationView()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(showEditMode))
		
		// Disallow multiple selection
		self.collectionView.allowsMultipleSelection = false
		
		if selectedAssets.count > 0 {
			deselectAllAssets()
		}
		
		self.collectionView.reloadData()
	}
	
	func showAllImages() {
		self.isShowingLikeAssets = false
		self.showAllImagesButton.tintColor = UIColor.journeyMainColor
		self.showLikeImagesButton.tintColor = UIColor.lightGray
		
		self.initializeDateHeader()
		
		// If there's no asset on that schedule
		if self.dateHeader.count == 0 {
			self.noImageView.isHidden = false
		
		} else {
			self.noImageView.isHidden = true
		}
		
		// Hide No Like Image view
		self.noLikeImageView.isHidden = true
		
		self.collectionView.reloadData()
	}
	
	func showLikeImages() {
		self.isShowingLikeAssets = true
		self.showAllImagesButton.tintColor = UIColor.lightGray
		self.showLikeImagesButton.tintColor = UIColor.journeyMainColor
		
		self.initializePropertiesForLikeView()
		var likeAssets = [TravelAsset]()
		
		// Save dates whose the user chooses like assets
		for date in self.dateHeader {
			for asset in (self.schedule.assetsDict[date])! {
				if asset.isLike {
					self.likeDateHeaderSet.insert(date)
					likeAssets.append(asset)
				}
			}
		
			if likeAssets.count > 0 {
				likeAssets = likeAssets.sorted(by: { ($0.asset.creationDate)! < ($1.asset.creationDate)! })
				self.likeTravelAssetsDict[date] = likeAssets
				likeAssets = []
			
			}
		}
		
		// If there's no like asset
		if self.likeDateHeaderSet.count == 0 {
			self.noLikeImageView.isHidden = false
		
		} else {
			self.noLikeImageView.isHidden = true
			self.likeDateHeader = self.likeDateHeaderSet.sorted()
		}
		
		self.collectionView.reloadData()
	}
	
	func initializePropertiesForLikeView() {
		self.likeDateHeaderSet = []
		self.likeDateHeader = []
		self.likeTravelAssetsDict = [:]
	}
	
	func initializeDateHeader() {
		self.dateHeader = []
		
		for date in self.schedule.assetsDict.keys {
			if (schedule.assetsDict[date]?.count)! > 0 { dateHeader.append(date) }
		}
		
		// Sort section header in ascending order
		self.dateHeader = self.dateHeader.sorted()
	}
}

// MARK: - Implement methods of UICollectionViewDelegate and UICollectionViewDataSource

extension AssetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if self.isShowingLikeAssets { return self.likeDateHeader.count }
		return self.dateHeader.count
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
		
		if let headerView = reusableView as? AssetHeaderCollectionReusableView {
			let date: Date
			
			if self.isShowingLikeAssets {
				date = self.likeDateHeader[indexPath.section]
			
			} else {
				date = self.dateHeader[indexPath.section]
			}
			
			
			headerView.headerLabel.text = JourneyDate.formatted(date: date)
		}
		
		return reusableView
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if self.isShowingLikeAssets {
			let date: Date = self.likeDateHeader[section]
			return self.likeTravelAssetsDict[date]?.count ?? 0
		}
		
		let date: Date = self.dateHeader[section]
		return self.schedule.assetsDict[date]?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath)
		
		if let assetCell = cell as? AssetCollectionViewCell {
			let travelAsset: TravelAsset
			
			if self.isShowingLikeAssets {
				let date: Date = likeDateHeader[indexPath.section]
				travelAsset = (self.likeTravelAssetsDict[date])![indexPath.row]
				
			} else {
				let date: Date = dateHeader[indexPath.section]
				travelAsset = (self.schedule.assetsDict[date])![indexPath.row]
			}
			
			PHImageManager.default().requestImage(for: travelAsset.asset, targetSize: assetCell.assetImageView.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
				assetCell.assetImageView.image = image
			})
			
			if self.isEditMode && self.selectedAssets.contains(indexPath) {
				assetCell.effectView.isHidden = false
			
			} else {
				assetCell.effectView.isHidden = true
			}
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if isEditMode, let assetCell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell {
			assetCell.effectView.isHidden = false
			self.selectAsset(indexPath)
			return
		}
		
		let assets: [TravelAsset]
		
		if self.isShowingLikeAssets {
			let date: Date = self.likeDateHeader[indexPath.section]
			assets = (self.likeTravelAssetsDict[date])!
		
		} else {
			let date: Date = self.dateHeader[indexPath.section]
			assets = (self.schedule.assetsDict[date])!
		}
		
		let travelAsset: TravelAsset = assets[indexPath.row]
		performSegue(withIdentifier: "ShowDetailView", sender: travelAsset)
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if isEditMode {
			let assetCell = collectionView.cellForItem(at: indexPath) as! AssetCollectionViewCell
			assetCell.effectView.isHidden = true
			deselectAsset(indexPath)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? DetailViewController, let travelAsset = sender as? TravelAsset {
			controller.travelAsset = travelAsset
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

// MARK: - Toggle of Information View

extension AssetViewController {
	
	func showInformationView() {
		UIView.animate(withDuration: 0.3, animations: {
			self.informationView.frame.size.height = 37.0
		}) { (complete) in
			UIView.animate(withDuration: 0.1) {
				self.informationLabel.frame.size.height = 21.0
			}
		}
	}
	
	func hideInformationView() {
		UIView.animate(withDuration: 0.1, animations: {
			self.informationLabel.frame.size.height = 0.0
		}) { (complete) in
			UIView.animate(withDuration: 0.3) {
				self.informationView.frame.size.height = 0.0
			}
		}
	}
}
