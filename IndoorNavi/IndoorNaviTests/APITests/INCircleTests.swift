//
//  INCircleTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 28.08.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INCircleTests: XCTestCase {
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testCircleInit() {
        let circleInitPromise = expectation(description: "Marker initialized")
        
        map.load(Constants.FloorID) {
            let circle = INCircle(withMap: self.map)
            
            circle.position = INPoint(x: 480, y: 480)
            circle.color = .blue
            circle.border = INCircle.Border(width: 5, color: .red)
            circle.radius = 4
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(circle.objectID)
                circleInitPromise.fulfill()
            })
        }
        
        waitForExpectations(timeout: 15)
    }
}
