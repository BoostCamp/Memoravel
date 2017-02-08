//
//  Journey.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import UIKit

/**
여행 정보를 저장하는 가장 기본이 되는 데이터 구조입니다.
*/
struct Journey {
	
	var title: String
	var startDate: Date
	var endDate: Date
	var mainSchedule: [MainSchedule]
	var thumbnailImage: UIImage?
}
