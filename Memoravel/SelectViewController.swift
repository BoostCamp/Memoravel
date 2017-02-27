//
//  SelectViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/26/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import Photos
import MapKit

class SelectViewController: UIViewController {
	
	var journey: Journey!
	
	// Schedule 단위로 TravelAsset 을 하나의 배열에 묶어서 저장
	var assetsBySchedule = [[TravelAsset]]()
	
	// 선택된 cell 을 묶어서 PlayJourneyViewController 에 보내준다.
	var selectedAssets = [MKPlacemark : Set<TravelAsset>]()
	var selectedIndexPath = Set<IndexPath>()
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.allowsMultipleSelection = true
		
		// assetsBySchedule 에 데이터를 넣기 위한 함수를 호출
		self.addAssetsBySchedule()

    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// 선택된 이미지가 없을 경우에 다음 화면으로 넘어가지 못하도록 설정한다.
		self.nextButton.isEnabled = false
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		// PerformSegue 로 다음화면으로 넘어갈 때, 혹은 현재 화면에서 이전 화면으로 돌아갈 때 선택된 cell 을 초기화한다.
		if self.selectedAssets.count == 0 { return }

		// 선택된 collection view items 을 deselect 하고 effect view 를 숨겨준다.
		for indexPath in self.selectedIndexPath {
			self.collectionView.deselectItem(at: indexPath, animated: false)
			if let selectCell = self.collectionView.cellForItem(at: indexPath) as? SelectCollectionViewCell {
				selectCell.effectView.isHidden = true
			}
		}
		
		self.selectedIndexPath.removeAll()
		
		// selectedAssets 을 초기화한다.
		let locations = self.selectedAssets.keys
		
		for location in locations {
			self.selectedAssets[location]?.removeAll()
			self.selectedAssets[location] = nil
		}
	}

	func addAssetsBySchedule() {
		for schedule in self.journey.schedules {
			var totAssets = [TravelAsset]()
			let dates = schedule.assetsDict.keys
			
			for date in dates {
				let assets: [TravelAsset] = schedule.assetsDict[date]!
				
				for asset in assets {
					totAssets.append(asset)
				}
			}
			
			// Schedule 단위의 TravelAsset 을 하나의 배열에 묶은 후에 assetsBySchedule 에 저장
			self.assetsBySchedule.append(totAssets)
		}
	}
	
	@IBAction func moveToPlayJourney(_ sender: Any) {
		// 현재 선택된 이미지가 selectedAssets dictionary 에서 set 의 형태로 저장이 되어 있으므로 각 set 을 날짜순으로 sorting 한 후에 Play Journey 로 보내도록 한다.
		var resultAssets = [MKPlacemark : [TravelAsset]]()
		let locations = self.selectedAssets.keys
		
		for location in locations {
			if let assets = self.selectedAssets[location] {
				let sortedAssets: [TravelAsset] = assets.sorted(by: { ($0.asset?.creationDate)! <= ($1.asset?.creationDate)! })
				resultAssets[location] = sortedAssets
			}
		}
		
		self.performSegue(withIdentifier: "ShowPlayView", sender: resultAssets)
	}
	
	// TODO: PlayJourneyViewController 로 resultAssets 와 self.journey.schedules 를 보내준다.
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? PlayJourneyViewController, let resultAssets = sender as? [MKPlacemark : [TravelAsset]] {
			controller.journey = self.journey
			controller.schedules = self.journey.schedules
			controller.resultAssets = resultAssets
		}
	}
	
}

extension SelectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.journey.schedules.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.assetsBySchedule[section].count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectCell", for: indexPath)
		let travelAsset: TravelAsset = self.assetsBySchedule[indexPath.section][indexPath.row]
		
		if let selectCell = cell as? SelectCollectionViewCell {
			PHImageManager.default().requestImage(for: travelAsset.asset!, targetSize: selectCell.imageView.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
				selectCell.imageView.image = image
			})
			
			if selectCell.isSelected {
				selectCell.effectView.isHidden = false
			
			} else {
				selectCell.effectView.isHidden = true
			}
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
		
		if let header = reusableView as? SelectCollectionReusableView {
			header.headerLabel.text = JourneyAddress.parseDetailAddress(self.journey.schedules[indexPath.section].location)
		}
		
		return reusableView
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let selectCell = collectionView.cellForItem(at: indexPath) as? SelectCollectionViewCell {
			selectCell.effectView.isHidden = false
			let location: MKPlacemark = self.journey.schedules[indexPath.section].location
			
			// 만약 해당 location 에 저장된 asset 이 없으면 새로 추가
			if self.selectedAssets[location] == nil {
				self.selectedAssets[location] = Set<TravelAsset>()
			}
		
			self.selectedAssets[location]?.insert(self.assetsBySchedule[indexPath.section][indexPath.row])
			self.selectedIndexPath.insert(indexPath)
			
			// TODO: DELETE THIS TEST CODE
			print("\(JourneyAddress.parseTitleAddress(location)!) 의 데이터 개수: \((self.selectedAssets[location]?.count)!)")
			
			// Next 버튼을 활성화 한다
			self.nextButton.isEnabled = true
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if let selectCell = collectionView.cellForItem(at: indexPath) as? SelectCollectionViewCell {
			selectCell.effectView.isHidden = true
			let location: MKPlacemark = self.journey.schedules[indexPath.section].location
			let _ = self.selectedAssets[location]?.remove(self.assetsBySchedule[indexPath.section][indexPath.row])
			self.selectedIndexPath.remove(indexPath)
			
			// TODO: DELETE THIS TEST CODE
			print("\(JourneyAddress.parseTitleAddress(location)!) 의 데이터 개수: \((self.selectedAssets[location]?.count)!)")
			
			// 만약 해당 location 에 저장된 asset 의 개수가 0개가 되면 해당 location 도 dictionary 에서 삭제
			if self.selectedAssets[location]?.count == 0 {
				self.selectedAssets[location] = nil
				
				// 만약 선택된 이미지가 하나도 없다면 next button 을 다시 비활성화 한다.
				if self.selectedAssets.count == 0 {
					self.nextButton.isEnabled = false
				}
			}
		}
	}
}

// MARK: - Implement methods of UICollectionViewDelegateFlowLayout

extension SelectViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width: CGFloat = collectionView.frame.width / 4 - 1
		return CGSize(width: width, height: width)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 1.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 1.0
	}
}
