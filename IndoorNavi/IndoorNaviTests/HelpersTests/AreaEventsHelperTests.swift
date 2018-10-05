//
//  AreaEventsHelperTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 25.06.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class AreaEventsHelperTests: XCTestCase {
    
    func testAreaEventsFromJSON() {
        let areaEvents = [AreaEvent(tagID: 18, date: Date(timeIntervalSince1970: 1428200000), areaID: 3, areaName: "Hala 1", mode: .onEnter), AreaEvent(tagID: 10, date: Date(timeIntervalSince1970: 1428100000), areaID: 6, areaName: "Hala 2", mode: .onLeave)]
        let areaEventsDictionary: Any = [["date": Date(timeIntervalSince1970: 1428200000), "tagId": 18, "areaId": 3, "areaName": "Hala 1", "mode": "ON_ENTER"], ["date": Date(timeIntervalSince1970: 1428100000), "tagId": 10, "areaId": 6, "areaName": "Hala 2", "mode": "ON_LEAVE"]]
        
        let areaEventsArray = AreaEventsHelper.areaEvents(fromJSONObject: areaEventsDictionary)
        XCTAssertEqual(areaEventsArray, areaEvents)
    }
}
