//
//  INMapTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 02.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INMapTests: XCTestCase {
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
    }

    override func tearDown() {
        map = nil
    }
    
    func testMapLoad() {
        let loadMapPromise = expectation(description: "Map with ID 2 loaded.")
        let scaleExpectation = expectation(description: "Scale downloaded.")
        
        map.load(Constants.FloorID) {
            loadMapPromise.fulfill()
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(self.map.scale)
                scaleExpectation.fulfill()
            })
        }
        
        waitForExpectations(timeout: 15)
    }
    
    func testGetComplexes() {
        let getComplexesPromise = expectation(description: "Complexes downloaded.")
        
        map.load(Constants.FloorID) {
            self.map.getComplexes { complexes in
                XCTAssertNotEqual(complexes.count, 0)
                getComplexesPromise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testPullToPath() {
        let pullToPathPromise = expectation(description: "Pulled to path.")
        
        let point = INPoint(x: 1305, y: 396)
        map.load(Constants.FloorID) {
            self.map.pullToPath(point: point, accuracy: 10000) { point in
                pullToPathPromise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
