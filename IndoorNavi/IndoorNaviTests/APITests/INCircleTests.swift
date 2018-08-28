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

    let FrontendTargetHost = "http://172.16.170.6:4200"
    let ApiKey = "TestAdmin"
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: FrontendTargetHost, apiKey: ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testCircleInit() {
        let circleInitPromise = expectation(description: "Marker initialized")
        
        map.load(2) {
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
