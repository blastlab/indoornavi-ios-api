//
//  ColorHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class ColorHelper: NSObject {
    
    static func colorString(fromColor color: UIColor) -> String {
        let colorString = colorStringFromColorComponents(red: color.rgba.red, green: color.rgba.green, blue: color.rgba.blue)
        return colorString
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

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}
