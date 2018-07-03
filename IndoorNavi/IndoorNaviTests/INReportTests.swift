//
//  INReportTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 03.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INReportTests: XCTestCase {

    let FrontendTargetHost = "http://172.16.170.53:4200"
    let BackendTargetHost = "http://172.16.170.53:90"
    let ApiKey = "TestAdmin"
    
    var map: INMap!
    var report: INReport!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: FrontendTargetHost, apiKey: ApiKey)
        report = INReport(map: map, targetHost: BackendTargetHost, apiKey: ApiKey)
    }
    
    override func tearDown() {
        map = nil
        report = nil
    }
    
    func testMapInit() {
        XCTAssertNotNil(map)
    }
    
    func testReportInit() {
        XCTAssertNotNil(report)
    }
    
    func testGetAreaEvents() {
        let loadMapPromise = expectation(description: "Map loaded.")
        let getAreaEventsResponse = expectation(description: "getAreaEvents response arrived")
        
        map.load(2) {
            loadMapPromise.fulfill()
            self.report.getAreaEvents(fromFloorWithID: 2, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { areaEvents in
                getAreaEventsResponse.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testGetCoordinates() {
        let loadMapPromise = expectation(description: "Map loaded.")
        let getCoordinatesResponse = expectation(description: "getCoordinates response arrived")
        
        map.load(2) {
            loadMapPromise.fulfill()
            self.report.getCoordinates(fromFloorWithID: 2, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { coordinates in
                getCoordinatesResponse.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
