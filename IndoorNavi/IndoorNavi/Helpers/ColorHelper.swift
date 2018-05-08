//
//  ColorHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class ColorHelper: NSObject {
    
    static func colorStringFromColorComponents(red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        let standarizedRed = Int(standarize(value: red) * 255)
        let standarizedGreen = Int(standarize(value: green) * 255)
        let standarizedBlue = Int(standarize(value: blue) * 255)
        print("Red: \(standarizedRed), Green: \(standarizedGreen), Blue: \(standarizedBlue)")
        let colorString = String(format: "rgb(%i,%i,%i)", standarizedRed, standarizedGreen, standarizedBlue)
        print("Color string: ",colorString)
        return colorString
    }
    
    static func standarizedOpacity(fromValue value: CGFloat) -> CGFloat {
        let standarizedOpacity = standarize(value: value)
        return standarizedOpacity
    }
    
    static private func standarize(value: CGFloat) -> CGFloat {
        return min(max(value, 0), 1)
    }
}
