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
	
	var asset: PHAsset!
	
	@IBOutlet weak var backgroundCardView: UIView!
	@IBOutlet weak var assetImageView: UIImageView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

		// Show asset image in UIImageView
		PHImageManager.default().requestImage(for: asset, targetSize: assetImageView.frame.size, contentMode: .aspectFill,
		                                      options: nil, resultHandler: { (image, info) in
			self.assetImageView.image = image
		})
		
		// Show location information in UILabel
		locationLabel.numberOfLines = 0
		locationLabel.sizeToFit()
		
		if let location = asset.location {
			CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
				if let placemark = placemarks?.first, let addressDict = placemark.addressDictionary as? [String : Any], let coordinate = placemark.location?.coordinate {
					let mkPlacemark: MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
//					print("Address: \(JourneyAddress.parseDetailAddress(mkPlacemark))")
					self.locationLabel.text = JourneyAddress.parseDetailAddress(mkPlacemark)
				}
			})
			
		} else {
			locationLabel.text = "No location information"
		}
		
		// Show date information in UILabel
		if let creationDate = asset.creationDate {
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
    }

}
