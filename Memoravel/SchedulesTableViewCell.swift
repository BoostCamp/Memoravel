//
//  SchedulesTableViewCell.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/12/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class SchedulesTableViewCell: UITableViewCell {

	var tapAction: ((UITableViewCell) -> Void)?
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	
	@IBAction func showAssets(_ sender: Any) {
		tapAction?(self)
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
