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
    
    let FrontendTargetHost = "http://172.16.170.53:4200"
    let ApiKey = "TestAdmin"
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: FrontendTargetHost, apiKey: ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testAreaInit() {
        let areaInitPromise = expectation(description: "Area initialized")
        
        map.load(2) {
            let area = INArea(withMap: self.map)
            let points = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220), INPoint(x: 750, y: 750)]
            
            area.set(points: points)
            area.setFillColor(red: 0.8, green: 0.4, blue: 0.2)
            area.setOpacity(0.5)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(area.objectID)
                areaInitPromise.fulfill()
            })
            
            area.getPoints { points in
                XCTAssertNotNil(points)
            }
            
            area.isWithin(coordinates: [INPoint(x: 200, y: 400)]) { isWithin in
                XCTAssertNotNil(isWithin)
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
