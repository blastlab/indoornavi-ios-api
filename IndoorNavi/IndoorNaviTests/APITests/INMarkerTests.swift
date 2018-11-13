//
//  INMarker.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 03.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class INMarkerTests: XCTestCase {
    
    var map: INMap!
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: Constants.FrontendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testMarkerInit() {
        let markerInitPromise = expectation(description: "Marker initialized")
        
        map.load(Constants.FloorID) {
            let marker = INMarker(withMap: self.map)
            
            marker.position = INPoint(x: 480, y: 480)
            marker.iconPath = "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png"
            marker.label = "Tekst ABCD"
            marker.addEventListener {}
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(marker.objectID)
                markerInitPromise.fulfill()
            })
        }
        
        waitForExpectations(timeout: 15)
    }
}
