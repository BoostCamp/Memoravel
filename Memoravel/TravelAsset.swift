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
class TravelAsset: NSObject, NSCoding {
	
	var asset: PHAsset
	var isLike: Bool
	var comment: String
	
	init(asset: PHAsset, isLike: Bool = false, comment: String = "") {
		self.asset = asset
		self.isLike = isLike
		self.comment = comment
	}
	
	override var hashValue: Int {
		return self.asset.hashValue
	}
	
	static func == (lhs: TravelAsset, rhs: TravelAsset) -> Bool {
		return lhs.asset == rhs.asset
	}
	
	required convenience init(coder aDecoder: NSCoder) {
		let identifier = aDecoder.decodeObject(forKey: "identifier") as! String
		let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
		let asset: PHAsset = (fetchResult.firstObject)!
		let isLike = aDecoder.decodeBool(forKey: "isLike")
		let comment = aDecoder.decodeObject(forKey: "comment") as! String
		
		self.init(asset: asset, isLike: isLike, comment: comment)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(asset.localIdentifier, forKey: "identifier")
		aCoder.encode(isLike, forKey: "isLike")
		aCoder.encode(comment, forKey: "comment")
	}
}
