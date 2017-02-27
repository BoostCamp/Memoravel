//
//  SelectCollectionViewCell.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/26/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class SelectCollectionViewCell: UICollectionViewCell {
 
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var effectView: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.effectView.isHidden = true
	}
}
