//
//  MasterTableViewCell.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class MasterTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var thumbnailImageView: UIImageView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
