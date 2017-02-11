//
//  Schedule.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import MapKit

/**
일정 정보를 저장하는 데이터 구조입니다.
- Main schedule 및 Sub schedule 에서 사용합니다.
*/
struct Schedule {
	
	var location: MKPlacemark
	var startDate: Date
	var endDate: Date
}
