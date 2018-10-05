//
//  CoordinatesHelperTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 28.06.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class CoordinatesHelperTests: XCTestCase {

    func testCoordinatesFromJSON() {
        let coordinates = [IndoorNavi.Coordinates(x: 500, y: 1500, tagID: 13999, date: Date(timeIntervalSince1970: 1451602800)), IndoorNavi.Coordinates(x: 1500, y: 1500, tagID: 13999, date: Date(timeIntervalSince1970: 1451602800)), IndoorNavi.Coordinates(x: 2500, y: 1500, tagID: 13999, date: Date(timeIntervalSince1970: 1451602800))]
        let coordinatesDictionary: Any = [["date": Date(timeIntervalSince1970: 1451602800), "tagId": 13999, "x": 500, "y": 1500], ["date": Date(timeIntervalSince1970: 1451602800), "tagId": 13999, "x": 1500, "y": 1500], ["date": Date(timeIntervalSince1970: 1451602800), "tagId": 13999, "x": 2500, "y": 1500]]
        
        let coordinatesArray = CoordinatesHelper.coordinatesArray(fromJSONObject: coordinatesDictionary)
        XCTAssertEqual(coordinatesArray, coordinates)
    }
}
