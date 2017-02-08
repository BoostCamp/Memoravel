//
//  MainSchedule.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation

/**
Main schedule 정보를 저장하는 데이터 구조입니다.
*/
struct MainSchedule {
	
	var schedule: Schedule
	var subSchedule: [Schedule]?
}
