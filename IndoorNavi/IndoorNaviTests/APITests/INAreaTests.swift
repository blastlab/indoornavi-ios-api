//
//  INAreaTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 03.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INAreaTests: XCTestCase {
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testAreaInit() {
        let areaInitPromise = expectation(description: "Area initialized")
        let areaIsWithin1Promise = expectation(description: "Is Within 1")
        let areaIsWithin2Promise = expectation(description: "Is Within 2")
        
        map.load(Constants.FloorID) {
            let area = INArea(withMap: self.map)
            let points = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220)]
            
            area.points = points
            area.color = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.5)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(area.objectID)
                areaInitPromise.fulfill()
            })
            
            area.isWithin(coordinates: INPoint(x: 600, y: 600)) { isWithin in
                XCTAssertTrue(isWithin ?? false)
                areaIsWithin1Promise.fulfill()
            }
            
            area.isWithin(coordinates: INPoint(x: 100, y: 100)) { isWithin in
                XCTAssertFalse(isWithin ?? true)
                areaIsWithin2Promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
