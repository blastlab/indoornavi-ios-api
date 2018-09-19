//
//  INPolylineTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 03.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INPolylineTests: XCTestCase {
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testPolylineInit() {
        let polylineInitPromise = expectation(description: "Polyline initialized")
        
        map.load(Constants.FloorID) {
            let polyline = INPolyline(withMap: self.map)
            let points = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220), INPoint(x: 750, y: 750)]
            
            polyline.points = points
            polyline.color = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(polyline.objectID)
                polylineInitPromise.fulfill()
            })
        }
        
        waitForExpectations(timeout: 15)
    }
}
