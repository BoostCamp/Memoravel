//
//  MasterTableViewCell.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class MasterTableViewCell: UITableViewCell {
	
	@IBOutlet weak var backgroundCardView: UIView!
	@IBOutlet weak var thumbnailImageView: UIImageView!
	@IBOutlet weak var journeyTitle: UILabel!
	@IBOutlet weak var journeyDate: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		// Initialization code
		backgroundCardView.backgroundColor = UIColor.journeyMainColor
		backgroundCardView.layer.cornerRadius = 3.0
		backgroundCardView.layer.masksToBounds = false
		
		// Settings for shadow of background view
		backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
		backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
		backgroundCardView.layer.shadowOpacity = 0.8
		
		// Set to darken a thumbnail image
		let overlay = UIView(frame: self.thumbnailImageView.frame)
		overlay.backgroundColor = UIColor.black
		overlay.alpha = 0.5
		self.thumbnailImageView.addSubview(overlay)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
