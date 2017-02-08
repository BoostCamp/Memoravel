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
여행 사진 또는 동영상 정보를 저장하는 데이터 구조입니다.
*/
struct TravelAsset {
	
	var asset: PHAsset
	var creationDate: Date
	var creationLocation: CLLocation
	
	var isLike: Bool = false
	var comment: String?
}
