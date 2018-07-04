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
    
    let FrontendTargetHost = "http://172.16.170.53:4200"
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
        
        map.load(2) {
            loadMapPromise.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
}
