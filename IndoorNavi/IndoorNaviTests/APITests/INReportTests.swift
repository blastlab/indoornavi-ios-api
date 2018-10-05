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
    
    var map: INMap!
    var report: INReport!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
        report = INReport(map: map, targetHost: Constants.BackendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        map = nil
        report = nil
    }
    
    func testGetAreaEvents() {
        let getAreaEventsResponsePromise = expectation(description: "getAreaEvents response arrived")
        
        map.load(Constants.FloorID) {
            self.report.getAreaEvents(fromFloorWithID: Constants.FloorID, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { areaEvents in
                getAreaEventsResponsePromise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15)
    }
    
    func testGetCoordinates() {
        let getCoordinatesResponsePromise = expectation(description: "getCoordinates response arrived")
        
        map.load(Constants.FloorID) {
            self.report.getCoordinates(fromFloorWithID: Constants.FloorID, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { coordinates in
                getCoordinatesResponsePromise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15)
    }
}
