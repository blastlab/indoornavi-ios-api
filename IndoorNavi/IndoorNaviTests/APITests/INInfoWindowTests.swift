//
//  INInforWindowTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 03.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INInfoWindowTests: XCTestCase {
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testInfoWindowInit() {
        let infoWindowInitPromise = expectation(description: "InfoWindow initialized")
        
        map.load(Constants.FloorID) {
            let infoWindow = INInfoWindow(withMap: self.map)
            
            infoWindow.content = "<h2>Lorem ipsum dolor sit amet</h2>"
            infoWindow.position = .top
            infoWindow.height = 300
            infoWindow.width = 400
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(infoWindow.objectID)
                infoWindowInitPromise.fulfill()
            })
        }
        
        waitForExpectations(timeout: 15)
    }
}
