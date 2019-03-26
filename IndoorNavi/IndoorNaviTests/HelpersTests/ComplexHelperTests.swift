//
//  ComplexHelperTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 05/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

let complexes1 = [Complex(id: 1, name: "Complex 1", buildings: buildingsC1), Complex(id: 2, name: "Complex 2", buildings: buildingsC2)]
let complexes2 = [Complex(id: 1, name: "Kompleks 1", buildings: buildingsC1), Complex(id: 2, name: "Kompleks 2", buildings: buildingsC2)]

let buildingsC1 = [Building(id: 1, name: "A", floors: floorsA), Building(id: 2, name: "B", floors: floorsB), Building(id: 3, name: "C", floors: floorsC)]
let buildingsC2 = [Building(id: 1, name: "D", floors: floorsA), Building(id: 2, name: "E", floors: floorsB), Building(id: 3, name: "F", floors: floorsC)]

let floorsA = [Floor(id: 1, name: "Parter", level: 0), Floor(id: 2, name: "I piętro", level: 1), Floor(id: 3, name: "II piętro", level: 2)]
let floorsB = [Floor(id: 4, name: "Garaż", level: 0), Floor(id: 5, name: "I p", level: 1), Floor(id: 6, name: "II p", level: 2)]
let floorsC = [Floor(id: 7, name: "Ground", level: 0), Floor(id: 8, name: "I level", level: 1), Floor(id: 9, name: "II level", level: 2)]

let complexes1Dictionary: Any = ["complexes": [["id": 1, "name": "Complex 1", "buildings": buildingsC1Dictionary], ["id": 2, "name": "Complex 2", "buildings": buildingsC2Dictionary]]]
let complexes2Dictionary: Any = ["complexes": [["id": 1, "name": "Kompleks 1", "buildings": buildingsC1Dictionary], ["id": 2, "name": "Kompleks 2", "buildings": buildingsC2Dictionary]]]

let buildingsC1Dictionary: Any = [["id": 1, "name": "A", "floors": floorsADictionary], ["id": 2, "name": "B", "floors": floorsBDictionary], ["id": 3, "name": "C", "floors": floorsCDictionary]]
let buildingsC2Dictionary: Any = [["id": 1, "name": "D", "floors": floorsADictionary], ["id": 2, "name": "E", "floors": floorsBDictionary], ["id": 3, "name": "F", "floors": floorsCDictionary]]

let floorsADictionary: Any = [["id": 1, "level": 0, "name": "Parter"], ["id": 2, "level": 1, "name": "I piętro"], ["id": 3, "level": 2, "name": "II piętro"]]
let floorsBDictionary: Any = [["id": 4, "level": 0, "name": "Garaż"], ["id": 5, "level": 1, "name": "I p"], ["id": 6, "level": 2, "name": "II p"]]
let floorsCDictionary: Any = [["id": 7, "level": 0, "name": "Ground"], ["id": 8, "level": 1, "name": "I level"], ["id": 9, "level": 2, "name": "II level"]]

class ComplexHelperTests: XCTestCase {
    
    func testComplexesFromJSON() {
        
        let data1 = try? JSONSerialization.data(withJSONObject: complexes1Dictionary, options: .prettyPrinted)
        let data2 = try? JSONSerialization.data(withJSONObject: complexes2Dictionary, options: .prettyPrinted)
        
        guard let complexesData1 = data1, let complexesData2 = data2 else {
            XCTFail()
            return
        }
        
        let array1 = try? JSONDecoder().decode([Complex].self, from: complexesData1)
        let array2 = try? JSONDecoder().decode([Complex].self, from: complexesData2)
        
        guard let complexesArray1 = array1, let complexesArray2 = array2 else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(complexesArray1, complexes1)
        XCTAssertEqual(complexesArray2, complexes2)
    }
    
    func testBuildingsFromJSON() {
        
        let data1 = try? JSONSerialization.data(withJSONObject: buildingsC1Dictionary, options: .prettyPrinted)
        let data2 = try? JSONSerialization.data(withJSONObject: buildingsC2Dictionary, options: .prettyPrinted)
        
        guard let buildingsData1 = data1, let buildingsData2 = data2 else {
            XCTFail()
            return
        }
        
        let array1 = try? JSONDecoder().decode([Building].self, from: buildingsData1)
        let array2 = try? JSONDecoder().decode([Building].self, from: buildingsData2)
        
        guard let buildingsArrayC1 = array1, let buildingsArrayC2 = array2 else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(buildingsArrayC1, buildingsC1)
        XCTAssertEqual(buildingsArrayC2, buildingsC2)
    }
    
    func testFloorsFromJSON() {
        
        let data1 = try? JSONSerialization.data(withJSONObject: floorsADictionary, options: .prettyPrinted)
        let data2 = try? JSONSerialization.data(withJSONObject: floorsBDictionary, options: .prettyPrinted)
        let data3 = try? JSONSerialization.data(withJSONObject: floorsCDictionary, options: .prettyPrinted)
        
        guard let floorsData1 = data1, let floorsData2 = data2, let floorsData3 = data3 else {
            XCTFail()
            return
        }
        
        let array1 = try? JSONDecoder().decode([Floor].self, from: floorsData1)
        let array2 = try? JSONDecoder().decode([Floor].self, from: floorsData2)
        let array3 = try? JSONDecoder().decode([Floor].self, from: floorsData3)
        
        guard let floorsArrayA = array1, let floorsArrayB = array2, let floorsArrayC = array3 else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(floorsArrayA, floorsA)
        XCTAssertEqual(floorsArrayB, floorsB)
        XCTAssertEqual(floorsArrayC, floorsC)
    }
}
