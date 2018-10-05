//
//  DataHelperTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 04/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class DataHelperTests: XCTestCase {
    
    func testPathsFromJSON() {
        let paths = [Path(startPoint: INPoint(x: 1, y: 2), endPoint: INPoint(x: 2, y: 1)), Path(startPoint: INPoint.zero, endPoint: INPoint(x: Int32.max, y: Int32.max)), Path(startPoint: INPoint(x: 500, y: 1000), endPoint: INPoint(x: 501, y: 1001))]
        let pathsDictionary: Any = [["startPoint": ["x": 1, "y": 2], "endPoint": ["x": 2, "y": 1]], ["startPoint": ["x": 0, "y": 0], "endPoint": ["x": Int32.max, "y": Int32.max]], ["startPoint": ["x": 500, "y": 1000], "endPoint": ["x": 501, "y": 1001]]]
        
        let pathsArray = DataHelper.paths(fromJSONObject: pathsDictionary)
        XCTAssertEqual(pathsArray, paths)
    }
}
