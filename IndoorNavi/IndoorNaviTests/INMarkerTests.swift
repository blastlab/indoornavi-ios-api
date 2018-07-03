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
    
    let FrontendTargetHost = "http://172.16.170.53:4200"
    let ApiKey = "TestAdmin"
    
    var map: INMap!
    let points: INPoint = INPoint(x: 480, y: 480)
    
    override func setUp() {
        map = INMap(frame: CGRect.zero, targetHost: FrontendTargetHost, apiKey: ApiKey)
    }
    
    override func tearDown() {
        map = nil
    }
    
    func testMapInit() {
        XCTAssertNotNil(map)
    }
    
    func testMarkerInit() {
        let loadMapPromise = expectation(description: "Map loaded.")
        let markerInitPromise = expectation(description: "Area initialized")
        
        map.load(2) {
            loadMapPromise.fulfill()
            let marker = INMarker(withMap: self.map)
            
            marker.set(point: INPoint(x: 600, y: 600))
            marker.setIcon(withPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png")
            marker.setLabel(withText: "Tekst ABCD")
            marker.addEventListener {}
            marker.draw()
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                XCTAssertNotNil(marker.objectID)
                markerInitPromise.fulfill()
            })
            
            marker.getPoints { points in
                XCTAssertNotNil(points)
            }
            
            marker.isWithin(coordinates: [INPoint(x: 200, y: 400)]) { isWithin in
                XCTAssertNotNil(isWithin)
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
