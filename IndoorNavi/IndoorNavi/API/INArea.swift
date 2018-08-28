//
//  INArea.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 27.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an `INArea`, communicates with frontend server and draws Area.
public class INArea: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "area%u"
        static let Initialization = "var %@ = new INArea(navi);"
        static let SetPoints = "%@.setPoints(points);"
        static let Draw = "%@.draw();"
        static let SetFillColor = "%@.setColor('%@')"
        static let SetOpacity = "%@.setOpacity('%f')"
        static let PointsDeclaration = "var points = %@;"
        static let Remove = "%@.remove()"
    }
    
    /// Initializes a new `INArea` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map:  An `INMap` object, in which `INArea` is going to be created.
    ///   - points: Array of Point's that are describing area in real world dimensions. Coordinates are calculated to the map scale and then displayed. For less than 3 points supplied to this method, Area isn't going to be drawn.
    ///   - color: Area's fill color and opacity.
    public convenience init(withMap map: INMap, points: [INPoint]? = nil, color: UIColor? = nil) {
        self.init(withMap: map)
        self.points = points ?? [INPoint]()
        if let color = color {
            self.color = color
            applyColorInJavaScript()
        }
        draw()
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, pointsArray: UnsafePointer<INPoint>, withArraySize size:Int) {
        let points = PointHelper.pointsArray(fromCArray: pointsArray, withSize: size)
        self.init(withMap: map, points: points)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, pointsArray: UnsafePointer<INPoint>, withArraySize size:Int, color: UIColor) {
        let points = PointHelper.pointsArray(fromCArray: pointsArray, withSize: size)
        self.init(withMap: map, points: points, color: color)
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Place Area on the map with all given settings. There is necessary to use `points()` before `draw()` to indicate where area should to be located.
    /// Use of this method is indispensable to draw area with set configuration in the IndoorNavi Map.
    @objc public func draw() {
        let javaScriptString = String(format: ScriptTemplates.Draw, self.javaScriptVariableName)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Array of Point's that is describing area in real world dimensions. Coordinates needs to be given as real world dimensions that map is representing. For less than 3 points supplied to this method, Area isn't going to be drawn. Use of this method is indispensable.
    public var points = [INPoint]() {
        didSet {
            let pointsString = PointHelper.pointsString(fromCoordinatesArray: points)
            let javaScriptString = String(format: ScriptTemplates.SetPoints, self.javaScriptVariableName)
            ready {
                self.map.evaluate(javaScriptString: String(format: ScriptTemplates.PointsDeclaration, pointsString))
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc(setPointsArray:withArraySize:) public func set(pointsArray: UnsafePointer<INPoint>, withArraySize size:Int) {
        self.points = PointHelper.pointsArray(fromCArray: pointsArray, withSize: size)
    }
    
    /// `INArea`'s fill color and opacity. To apply this it's necessary to call `draw()` after. Default value is `.black`.
    @objc public var color: UIColor = .black {
        didSet {
            applyColorInJavaScript()
        }
    }
    
    private func applyColorInJavaScript() {
        if let (red, green, blue, opacity) = ColorHelper.colorComponents(fromColor: color) {
            setColorInJavaScript(withRed: red, green: green, blue: blue)
            setOpacityInJavaScript(opacity: opacity)
        }
    }
    
    private func setColorInJavaScript(withRed red: CGFloat, green: CGFloat, blue: CGFloat) {
        let stringColor = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
        let javaScriptString = String(format: ScriptTemplates.SetFillColor, self.javaScriptVariableName, stringColor)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    private func setOpacityInJavaScript(opacity: CGFloat) {
        let standarizedOpacity = ColorHelper.standarizedOpacity(fromValue: opacity)
        let javaScriptString = String(format: ScriptTemplates.SetOpacity, self.javaScriptVariableName, standarizedOpacity)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
