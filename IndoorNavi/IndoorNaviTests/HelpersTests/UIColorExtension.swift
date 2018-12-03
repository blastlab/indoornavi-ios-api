//
//  UIColorExtension.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 25.06.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class UIColorExtensionTests: XCTestCase {

    func testColorStringFromComponents() {
        let color = UIColor(red: 0.5, green: 0.8, blue: 0.2, alpha: 1.0)
        let colorString = "rgb(127,204,51)"
        let colorStringFromComponents = color.colorString
        
        XCTAssertEqual(colorStringFromComponents, colorString)
    }
    
    func testStandarizedOpacityMax() {
        let standarizedOpacityMax = UIColor(red: 0.5, green: 0.8, blue: 0.2, alpha: 4.0).standarizedOpacity
        XCTAssertEqual(standarizedOpacityMax, 1)
    }
    
    func testStandarizedOpacityMin() {
        let standarizedOpacityMin = UIColor(red: 0.5, green: 0.8, blue: 0.2, alpha: -2.0).standarizedOpacity
        XCTAssertEqual(standarizedOpacityMin, 0)
    }
}
