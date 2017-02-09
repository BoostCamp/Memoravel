//
//  JourneyDate.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation

class JourneyDate {
	
	private static let dateFormatter = DateFormatter()
	
	// JourneyDate 인스턴스가 외부에서 생성되는 것을 방지합니다.
	private init() {}
	
	// 주어진 날짜를 해당 형식으로 변환합니다.
	static func formatted(date: Date) -> String {
		dateFormatter.dateFormat = "yyyy. MM. dd"
		return dateFormatter.string(from: date)
	}
}
