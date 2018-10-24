//
//  INDataTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 04/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INDataTests: XCTestCase {
    
    var map: INMap!
    var data: INData!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
        data = INData(map: map, targetHost: Constants.BackendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        map = nil
        data = nil
    }
    
    func testGetAreaEvents() {
        let getPathsResponsePromise = expectation(description: "Paths retrieved")
        
        map.load(Constants.FloorID) {
            self.data.getPaths(fromFloorWithID: Constants.FloorID) { paths in
                getPathsResponsePromise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15)
    }
}
