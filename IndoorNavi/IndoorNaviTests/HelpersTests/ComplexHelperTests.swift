//
//  ComplexHelperTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 05/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

let complexes1 = [Complex(identifier: 1, name: "Complex 1", buildings: buildingsC1), Complex(identifier: 2, name: "Complex 2", buildings: buildingsC2)]
let complexes2 = [Complex(identifier: 1, name: "Kompleks 1", buildings: buildingsC1), Complex(identifier: 2, name: "Kompleks 2", buildings: buildingsC2)]

let buildingsC1 = [Building(identifier: 1, name: "A", floors: floorsA), Building(identifier: 2, name: "B", floors: floorsB), Building(identifier: 3, name: "C", floors: floorsC)]
let buildingsC2 = [Building(identifier: 1, name: "D", floors: floorsA), Building(identifier: 2, name: "E", floors: floorsB), Building(identifier: 3, name: "F", floors: floorsC)]

let floorsA = [Floor(identifier: 1, name: "Parter", level: 0), Floor(identifier: 2, name: "I piętro", level: 1), Floor(identifier: 3, name: "II piętro", level: 2)]
let floorsB = [Floor(identifier: 4, name: "Garaż", level: 0), Floor(identifier: 5, name: "I p", level: 1), Floor(identifier: 6, name: "II p", level: 2)]
let floorsC = [Floor(identifier: 7, name: "Ground", level: 0), Floor(identifier: 8, name: "I level", level: 1), Floor(identifier: 9, name: "II level", level: 2)]

let complexes1Dictionary: Any = ["complexes": [["id": 1, "name": "Complex 1", "buildings": buildingsC1Dictionary], ["id": 2, "name": "Complex 2", "buildings": buildingsC2Dictionary]]]
let complexes2Dictionary: Any = ["complexes": [["id": 1, "name": "Kompleks 1", "buildings": buildingsC1Dictionary], ["id": 2, "name": "Kompleks 2", "buildings": buildingsC2Dictionary]]]

let buildingsC1Dictionary: Any = [["id": 1, "name": "A", "floors": floorsADictionary], ["id": 2, "name": "B", "floors": floorsBDictionary], ["id": 3, "name": "C", "floors": floorsCDictionary]]
let buildingsC2Dictionary: Any = [["id": 1, "name": "D", "floors": floorsADictionary], ["id": 2, "name": "E", "floors": floorsBDictionary], ["id": 3, "name": "F", "floors": floorsCDictionary]]

let floorsADictionary: Any = [["id": 1, "level": 0, "name": "Parter"], ["id": 2, "level": 1, "name": "I piętro"], ["id": 3, "level": 2, "name": "II piętro"]]
let floorsBDictionary: Any = [["id": 4, "level": 0, "name": "Garaż"], ["id": 5, "level": 1, "name": "I p"], ["id": 6, "level": 2, "name": "II p"]]
let floorsCDictionary: Any = [["id": 7, "level": 0, "name": "Ground"], ["id": 8, "level": 1, "name": "I level"], ["id": 9, "level": 2, "name": "II level"]]

class ComplexHelperTests: XCTestCase {
    
    func testComplexesFromJSON() {
        let complexesArray1 = ComplexHelper.complexes(fromJSONObject: complexes1Dictionary)
        let complexesArray2 = ComplexHelper.complexes(fromJSONObject: complexes2Dictionary)
        
        XCTAssertEqual(complexesArray1, complexes1)
        XCTAssertEqual(complexesArray2, complexes2)
    }
    
    func testBuildingsFromJSON() {
        let buildingsArrayC1 = ComplexHelper.buildings(fromJSONObject: buildingsC1Dictionary)
        let buildingsArrayC2 = ComplexHelper.buildings(fromJSONObject: buildingsC2Dictionary)
        
        XCTAssertEqual(buildingsArrayC1, buildingsC1)
        XCTAssertEqual(buildingsArrayC2, buildingsC2)
    }
    
    func testFloorsFromJSON() {
        let floorsArrayA = ComplexHelper.floors(fromJSONObject: floorsADictionary)
        let floorsArrayB = ComplexHelper.floors(fromJSONObject: floorsBDictionary)
        let floorsArrayC = ComplexHelper.floors(fromJSONObject: floorsCDictionary)
        
        XCTAssertEqual(floorsArrayA, floorsA)
        XCTAssertEqual(floorsArrayB, floorsB)
        XCTAssertEqual(floorsArrayC, floorsC)
    }
}
