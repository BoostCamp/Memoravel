//
//  DetailViewController.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/7/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit
import Photos
import MapKit

class DetailViewController: UIViewController {
	
	var travelAsset: TravelAsset!
	
	@IBOutlet weak var backgroundCardView: UIView!
	@IBOutlet weak var assetImageView: UIImageView!
	@IBOutlet weak var thumbnailButton: UIButton!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var buttonBackgroundView: UIView!
	@IBOutlet weak var commentTextField: UITextField!
	
	// IBOutlets for Information view
	@IBOutlet weak var informationView: UIView!
	@IBOutlet weak var informationLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Show asset image in UIImageView
		PHImageManager.default().requestImage(for: travelAsset.asset!, targetSize: assetImageView.frame.size, contentMode: .aspectFill,
		                                      options: nil, resultHandler: { (image, info) in
			self.assetImageView.image = image
		})
		
		// Show location information in UILabel
		locationLabel.numberOfLines = 0
		locationLabel.sizeToFit()
		
		// Settings for navigation bar
		self.navigationController?.automaticallyAdjustsScrollViewInsets = false
		self.navigationController?.extendedLayoutIncludesOpaqueBars = true
		self.automaticallyAdjustsScrollViewInsets = false
		
		if let location = travelAsset.asset!.location {
			CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
				if let placemark = placemarks?.first, let addressDict = placemark.addressDictionary as? [String : Any], let coordinate = placemark.location?.coordinate {
					let mkPlacemark: MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
					self.locationLabel.text = JourneyAddress.parseDetailAddress(mkPlacemark)
				}
			})
			
		} else {
			locationLabel.text = "No location information"
		}
		
		// Show date information in UILabel
		if let creationDate = travelAsset.asset!.creationDate {
			dateLabel.text = JourneyDate.formatted(date: creationDate)
		
		} else {
			dateLabel.text = "No date information"
		}
		
		// Set navigation title
		navigationItem.title = "Detail"
		
		// Settings for UIImageView like a card view
		backgroundCardView.layer.cornerRadius = 3.0
		backgroundCardView.layer.masksToBounds = false
		backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
		backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
		backgroundCardView.layer.shadowOpacity = 0.8
		
		assetImageView.layer.cornerRadius = 3.0
		
		// Get shadow effect to the save current status button like card view
		buttonBackgroundView.layer.cornerRadius = 3.0
		buttonBackgroundView.layer.masksToBounds = false
		buttonBackgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
		buttonBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
		buttonBackgroundView.layer.shadowOpacity = 0.8
		
		// Settings for buttons
		if self.travelAsset.isLike { likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal) }
		self.thumbnailButton.setImage(#imageLiteral(resourceName: "pin_light"), for: .highlighted)
		self.shareButton.setImage(#imageLiteral(resourceName: "share"), for: .highlighted)
		
		// Set comment text field
		self.commentTextField.text = self.travelAsset.comment
		
		// Set delegate of text field
		self.commentTextField.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Register a notification about keyboard layout showing up
		subscribeToKeyboardNotification()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Cancel registration a notification about keyboard layout showing up
		unSubscribeToKeyboardNotification()
	}
	
	@IBAction func setAsThumbnail(_ sender: Any) {
		print("setAsThumbnail BUTTON WAS CLICKED")
		NotificationCenter.default.post(name: .beAboutToThumbnail, object: self.assetImageView.image)
		
		self.showInformationView()
	}
	
	@IBAction func shareImage(_ sender: Any) {
		if let image = self.assetImageView.image {
			let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
			self.present(controller, animated: true, completion: nil)
		}
	}
	
	@IBAction func changeLikeStatus(_ sender: UIButton) {
		if let image = sender.currentImage, image == #imageLiteral(resourceName: "dislike_bold") {
			sender.setImage(#imageLiteral(resourceName: "like"), for: .normal)
			self.travelAsset.isLike = true
		
		} else {
			sender.setImage(#imageLiteral(resourceName: "dislike_bold"), for: .normal)
			self.travelAsset.isLike = false
		}
	}

	@IBAction func saveTravelAsset(_ sender: Any) {
		self.travelAsset.comment = commentTextField.text!
		_ = self.navigationController?.popViewController(animated: true)
	}
}

// MARK: - Settings for NotificationCenter regarding to keyboard layout showing up

extension DetailViewController {
	
	func subscribeToKeyboardNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
	}
	
	func unSubscribeToKeyboardNotification() {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
	
	func keyboardWillShow(_ notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		
		if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
			var aRect = self.view.frame
			aRect.size.height -= keyboardSize.height
			
			// If keyboard layout covers text view
			if !(aRect.contains(self.commentTextField.frame.origin)) {
				self.view.frame.origin.y -= keyboardSize.height
			}
		}
	}
	
	func keyboardWillHide(_ notification: Notification) {
		self.view.frame.origin.y = 0
	}

}

// MARK: - Implement method of UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - Setting for custom NotificationCenter

extension Notification.Name {
	
	static let beAboutToThumbnail = Notification.Name("be_about_to_thumbnail")
}

// MARK: - Toggle of Information View

extension DetailViewController {
	
	func showInformationView() {
		UIView.animate(withDuration: 0.7, animations: {
			self.informationView.frame.size.height = 37.0
		}) { (didAppearView) in
			if didAppearView {
				UIView.animate(withDuration: 0.3, animations: { 
					self.informationLabel.frame.size.height = 21.0
				}, completion: { (didAppearLabel) in
					if didAppearLabel {
						sleep(1)
						UIView.animate(withDuration: 0.3, animations: { 
							self.informationLabel.frame.size.height = 0.0
						}, completion: { (didDisappearLabel) in
							if didDisappearLabel {
								UIView.animate(withDuration: 0.7, animations: { 
									self.informationView.frame.size.height = 0.0
								})
							}
						})
					}
				})
			}
		}
	}
}

