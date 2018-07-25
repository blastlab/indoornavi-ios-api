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
    
    let FrontendTargetHost = "http://172.16.170.18:4200"
    let ApiKey = "TestAdmin"
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: FrontendTargetHost, apiKey: ApiKey)
    }

    override func tearDown() {
        map = nil
    }
    
    func testMapLoad() {
        let loadMapPromise = expectation(description: "Map with ID 2 loaded.")
        let scaleExpectation = expectation(description: "Scale downloaded.")
        
        map.load(2) {
            loadMapPromise.fulfill()
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(self.map.scale)
                scaleExpectation.fulfill()
            })
        }
        
        waitForExpectations(timeout: 15)
    }
}
