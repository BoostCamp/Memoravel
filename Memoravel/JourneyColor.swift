//
//  JourneyColor.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/8/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
	convenience init(netHex:Int) {
		self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
	}
	
	class var journeyMainColor: UIColor { return UIColor(netHex: 0x424B5C) }
	class var journeySubColor: UIColor { return UIColor(netHex: 0xA6AEBB) }
	class var journeyLightColor: UIColor { return UIColor(netHex: 0xF9F9F9) }
	class var journeyWarningColor: UIColor { return UIColor(netHex: 0xED5836) }
}
