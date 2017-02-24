//
//  AssetCollectionViewCell.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/13/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var assetImageView: UIImageView!
	@IBOutlet weak var effectView: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		effectView.isHidden = true
	}
}
