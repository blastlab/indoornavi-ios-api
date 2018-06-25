//
//  ColorHelperTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 25.06.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class ColorHelperTests: XCTestCase {
    
    let (red, green, blue): (CGFloat, CGFloat, CGFloat) = (0.5, 0.8, 0.2)
    let colorString = "rgb(127,204,51)"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testColorStringFromComponents() {
        let colorStringFromComponents = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
        XCTAssertEqual(colorStringFromComponents, colorString)
    }
    
    func testStandarizedOpacityMax() {
        let standarizedOpacityMax = ColorHelper.standarizedOpacity(fromValue: 4)
        XCTAssertEqual(standarizedOpacityMax, 1)
    }
    
    func testStandarizedOpacityMin() {
        let standarizedOpacityMin = ColorHelper.standarizedOpacity(fromValue: -5)
        XCTAssertEqual(standarizedOpacityMin, 0)
    }
}
