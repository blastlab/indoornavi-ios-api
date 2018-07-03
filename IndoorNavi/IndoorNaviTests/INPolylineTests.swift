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

    let FrontendTargetHost = "http://172.16.170.53:4200"
    let ApiKey = "TestAdmin"
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: FrontendTargetHost, apiKey: ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testMapInit() {
        XCTAssertNotNil(map)
    }
    
    func testPolylineInit() {
        let loadMapPromise = expectation(description: "Map loaded.")
        let polylineInitPromise = expectation(description: "Polyline initialized")
        
        map.load(2) {
            loadMapPromise.fulfill()
            let polyline = INPolyline(withMap: self.map)
            let points: [INPoint] = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220), INPoint(x: 750, y: 750)]
            
            polyline.set(points: points)
            polyline.setColorWith(red: 1.0, green: 0.5, blue: 0.5)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(polyline.objectID)
                polylineInitPromise.fulfill()
            })
            
            polyline.getPoints { points in
                XCTAssertNotNil(points)
            }
            
            polyline.isWithin(coordinates: [INPoint(x: 200, y: 400)]) { isWithin in
                XCTAssertNotNil(isWithin)
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
