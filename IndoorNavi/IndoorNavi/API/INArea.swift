//
//  INArea.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 27.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an `INArea`, communicates with frontend server and draws area.
public class INArea: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "area%u"
        static let InitializationTemplate = "var %@ = new INArea(navi);"
        static let PointsTemplate = "%@.points(points);"
        static let DrawTemplate = "%@.draw();"
        static let SetFillColorTemplate = "%@.setFillColor('%@')"
        static let SetOpacityTemplate = "%@.setOpacity('%f')"
        static let PointsDeclaration = "var points = %@;"
    }
    
    /// Initializes a new `INArea` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map:  An `INMap` object, in which `INArea` is going to be created.
    ///   - points: Array of Point's that are describing area in real world dimensions. Coordinates are calculated to the map scale and then displayed. For less than 3 points supplied to this method, Area isn't going to be drawn.
    ///   - color: Area's fill color and opacity.
    public convenience init(withMap map: INMap, points: [INPoint]? = nil, color: UIColor? = nil) {
        self.init(withMap: map)
        if let points = points {
            set(points: points)
        }
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
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Place area on the map with all given settings. There is necessary to use `points()` before `draw()` to indicate where area should to be located.
    /// Use of this method is indispensable to draw area with set configuration in the IndoorNavi Map.
    @objc public func draw() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.DrawTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Locates area at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
    ///
    /// - Parameter points: Array of Point's that are describing area in real world dimensions. Coordinates are calculated to the map scale and then displayed. For less than 3 points supplied to this method, Area isn't going to be drawn.
    public func set(points: [INPoint]) {
        ready {
            let pointsString = PointHelper.pointsString(fromCoordinatesArray: points)
            self.map.evaluate(javaScriptString: String(format: ScriptTemplates.PointsDeclaration, pointsString))
            let javaScriptString = String(format: ScriptTemplates.PointsTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc(setPointsArray:withArraySize:) public func set(pointsArray: UnsafePointer<INPoint>, withArraySize size:Int) {
        var points = [INPoint]()
        for i in 0..<size {
            let pointer = pointsArray + i
            points.append(pointer.pointee)
        }
        set(points: points)
    }
    
    /// `INArea`'s fill color and opacity. To apply this it's necessary to call `draw()` after. Default value is `.black`.
    ///
    /// - Parameter color: Area's fill color and opacity.
    @objc public var color: UIColor = .black {
        didSet {
            applyColorInJavaScript()
        }
    }
    
    private func applyColorInJavaScript() {
        if let colorComponents = color.cgColor.components {
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let opacity = colorComponents[3]
            setColorInJavaScript(withRed: red, green: green, blue: blue)
            setOpacityInJavaScript(opacity: opacity)
        }
    }
    
    private func setColorInJavaScript(withRed red: CGFloat, green: CGFloat, blue: CGFloat) {
        ready {
            let stringColor = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
            let javaScriptString = String(format: ScriptTemplates.SetFillColorTemplate, self.javaScriptVariableName, stringColor)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    private func setOpacityInJavaScript(opacity: CGFloat) {
        ready {
            let standarizedOpacity = ColorHelper.standarizedOpacity(fromValue: opacity)
            let javaScriptString = String(format: ScriptTemplates.SetOpacityTemplate, self.javaScriptVariableName, standarizedOpacity)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
