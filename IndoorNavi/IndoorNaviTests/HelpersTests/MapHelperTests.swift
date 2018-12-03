//
//  MapHelperTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 09.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class MapHelperTests: XCTestCase {
    
    let scale = Scale(measure: .centimeters, realDistance: 200, start: INPoint(x: 100, y: 100), stop: INPoint(x: 500, y: 400))
    let realCoordinates = INPoint(x: 200, y: 200)
    let pixel = INPoint(x: 500, y: 500)

    func testRealCoordinatesFromPixel() {
        let realCoordinatesFromPixel = MapHelper.realCoordinates(fromPixel: pixel, scale: scale)
        XCTAssertEqual(realCoordinatesFromPixel, realCoordinates)
    }
    
    func testPixelFromRealCoordinates() {
        let pixelFromRealCoordinates = MapHelper.pixel(fromRealCoordinates: realCoordinates, scale: scale)
        XCTAssertEqual(pixelFromRealCoordinates, pixel)
    }
}
