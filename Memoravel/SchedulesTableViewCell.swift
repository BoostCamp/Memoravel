//
//  SchedulesTableViewCell.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/12/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class SchedulesTableViewCell: UITableViewCell {
	
	@IBOutlet weak var backgroundCardView: UIView!
	@IBOutlet weak var showLocationButton: UIButton!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	var showLocationAction: ((Int) -> Void)?
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		// Initialization code
		backgroundCardView.backgroundColor = UIColor.white
		backgroundCardView.layer.cornerRadius = 3.0
		backgroundCardView.layer.masksToBounds = false
		
		// Settings for shadow of background view
		backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
		backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
		backgroundCardView.layer.shadowOpacity = 0.8
    }
	
	@IBAction func showLocationOnTheMap(_ sender: Any) {
//		print("Row # \(self.showLocationButton.tag) is clicked!")
		
		if let action = self.showLocationAction {
			action(self.showLocationButton.tag)
		}
	}
}
