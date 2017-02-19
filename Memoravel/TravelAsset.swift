//
//  TravelAsset.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import Photos
import CoreLocation

/**
Save PHAsset and relative information
*/
class TravelAsset: Hashable {
	
	var asset: PHAsset
	var isLike: Bool
	var comment: String?
	
	init(asset: PHAsset, isLike: Bool = false, comment: String? = nil) {
		self.asset = asset
		self.isLike = isLike
		self.comment = comment
	}
	
	var hashValue: Int {
		return self.asset.hashValue
	}
	
	static func == (lhs: TravelAsset, rhs: TravelAsset) -> Bool {
		return lhs.asset == rhs.asset
	}
}
