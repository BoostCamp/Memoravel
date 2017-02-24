//
//  JourneyCoordinate.swift
//  Memoravel
//
//  Created by JUNYEONG.YOO on 2/23/17.
//  Copyright © 2017 Boostcamp. All rights reserved.
//

import Foundation
import MapKit
import GLKit

class JourneyCoordinate {
	
	private init() { }
	
	static func getCenterCoord(LocationPoints: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
		
		var x: Float = 0.0
		var y: Float = 0.0
		var z: Float = 0.0
		
		for points in LocationPoints {
			let lat = GLKMathDegreesToRadians(Float(points.latitude))
			let lng = GLKMathDegreesToRadians(Float(points.longitude))
			
			x += cos(lat) * cos(lng)
			y += cos(lat) * sin(lng)
			z += sin(lat)
		}
		
		x = x / Float(LocationPoints.count)
		y = y / Float(LocationPoints.count)
		z = z / Float(LocationPoints.count)
		
		let resultLng = atan2(y, x)
		let resultHyp = sqrt(x * x + y * y)
		let resultLat = atan2(z, resultHyp)
		
		let result = CLLocationCoordinate2D(latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))), longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLng))))
		
		return result
	}
}
