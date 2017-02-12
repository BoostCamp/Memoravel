//
//  CreateJourneyTableViewCell.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class CreateJourneyTableViewCell: UITableViewCell {

	@IBOutlet weak var backgroundCardView: UIView!
	@IBOutlet weak var locationButton: UIButton!
	@IBOutlet weak var startDateButton: UIButton!
	@IBOutlet weak var endDateButton: UIButton!
	@IBOutlet weak var initialView: UIView!
	
	@IBAction func addNewSchedule(_ sender: Any) {
		self.initialView.isHidden = true
	}
	
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
}
