//
//  ColorHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class ColorHelper: NSObject {
    
    static func colorString(fromColor color: UIColor) -> String? {
        if let (red, green, blue, _) = colorComponents(fromColor: color) {
            let colorString = colorStringFromColorComponents(red: red, green: green, blue: blue)
            return colorString
        }
        
        return nil
    }
    
    static func colorComponents(fromColor color: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat)? {
        if let colorComponents = color.cgColor.components {
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let opacity = colorComponents[3]
            return (red, green, blue, opacity)
        }
        
        return nil
    }
    
    static func colorStringFromColorComponents(red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        let standarizedRed = Int(standarize(value: red) * 255)
        let standarizedGreen = Int(standarize(value: green) * 255)
        let standarizedBlue = Int(standarize(value: blue) * 255)
        let colorString = String(format: "rgb(%i,%i,%i)", standarizedRed, standarizedGreen, standarizedBlue)
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
