//
//  IndoorNaviTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 29.03.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class PointHelperTests: XCTestCase {
    
    let points: [INPoint] = [INPoint(x: 1, y: 1), INPoint(x: 500, y: 1000), INPoint(x: 10000, y: 15000), INPoint(x: Int32.max, y: Int32.max), INPoint(x: 0, y: 0)]
    //pointsString    String    "[{x: 480, y: 480},{x: 1220, y: 480},{x: 1220, y: 1220},{x: 480, y: 1220},{x: 750, y: 750}]"
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPointsArrayToString() {
        let pointsStringFromArray = PointHelper.coordinatesArrayString(fromCoordinatesArray: points)
        XCTAssertEqual(pointsStringFromArray, "[{x: 1, y: 1},{x: 500, y: 1000},{x: 10000, y: 15000},{x: 2147483647, y: 2147483647},{x: 0, y: 0}]")
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
