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
    
    let points = [INPoint(x: 1, y: 1), INPoint(x: 500, y: 1000), INPoint(x: 10000, y: 15000), INPoint(x: Int32.max, y: Int32.max), INPoint(x: 0, y: 0)]
    let point = INPoint(x: 480, y: 480)
    let cgPoint = CGPoint(x: 1, y: 1)
    let pointsString = "[{x: 1, y: 1},{x: 500, y: 1000},{x: 10000, y: 15000},{x: 2147483647, y: 2147483647},{x: 0, y: 0}]"
    let pointString = "{x: 480, y: 480}"
    let pointsJson: [[String: Any]] = [["x": 1, "y": 1],["x": 500, "y": 1000],["x": 10000, "y": 15000],["x": 2147483647, "y": 2147483647],["x": 0, "y": 0]]
    
    func testCGPointToDictionary() {
        let pointsDictionary = PointHelper.pointDictionary(fromPoint: cgPoint) as [String: Any]
        
        let x1 = pointsDictionary["x"] as? String
        let y1 = pointsDictionary["y"] as? String
        let x2 = pointsJson[0]["x"] as? String
        let y2 = pointsJson[0]["y"] as? String
        
        XCTAssertEqual(x1, x2)
        XCTAssertEqual(y1, y2)
    }
    
    func testPointsArrayToString() {
        let pointsStringFromArray = PointHelper.pointsString(fromCoordinatesArray: points)
        XCTAssertEqual(pointsStringFromArray, pointsString)
    }
    
    func testPointsStringToArray() {
        let pointsArrayFromString = PointHelper.points(fromJSONObject: pointsJson)
        XCTAssertEqual(pointsArrayFromString, points)
    }
    
    func testPointToString() {
        let newPointString = PointHelper.pointString(fromCoordinates: point)
        XCTAssertEqual(newPointString, pointString)
    }
    
    func testCArrayToSwiftArray() {
        let newPoints = points
        let pointer = UnsafePointer<INPoint>(newPoints)
        let size = newPoints.count
        let swiftArray = PointHelper.pointsArray(fromCArray: pointer, withSize: size)
        XCTAssertEqual(swiftArray, points)
    }
    
    func testSwiftArrayToCArray() {
        let newPoints = points
        let (pointer, size) = PointHelper.pointsCArray(fromArray: newPoints)
        let swiftArray = Array((UnsafeBufferPointer(start: pointer, count: size)))
        XCTAssertEqual(swiftArray, points)
    }
}
