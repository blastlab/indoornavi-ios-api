//
//  UIColor+IndoorNavi.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
    
    var colorString: String {
        let standarizedRed = Int(UIColor.standarize(value: rgba.red) * 255)
        let standarizedGreen = Int(UIColor.standarize(value: rgba.green) * 255)
        let standarizedBlue = Int(UIColor.standarize(value: rgba.blue) * 255)
        let colorString = String(format: "rgb(%i,%i,%i)", standarizedRed, standarizedGreen, standarizedBlue)
        return colorString
    }
    
    var standarizedOpacity: CGFloat {
        let standarizedOpacity = UIColor.standarize(value: rgba.alpha)
        return standarizedOpacity
    }
    
    static var defaultNavigationColor: UIColor {
        return UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
    }
    
    static private func standarize(value: CGFloat) -> CGFloat {
        return min(max(value, 0), 1)
    }
}
