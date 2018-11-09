//
//  INCircle.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 27.08.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an `INCircle`, communicates with indoornavi frontend server and draws Circle.
public class INCircle: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "circle%u"
        static let Initialization = "var %@ = new INCircle(navi);"
        static let DrawTemplate = "%@.draw();"
        static let SetPosition = "%@.setPosition(%@);"
        static let SetRadius = "%@.setRadius(%d);"
        static let SetColor = "%@.setColor('%@');"
        static let SetOpacity = "%@.setOpacity(%f);"
        static let SetBorder = "%@.setBorder(%@);"
        static let Border = "new Border(%d, '%@')"
    }
    
    /// Initializes a new `INCircle` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map:  An `INMap` object, in which `INCircle` is going to be created.
    ///   - position: Point describing Circle's position in real world dimensions. Coordinates are calculated to the map scale and then displayed.
    ///   - color: Circles's fill color and opacity.
    public convenience init(withMap map: INMap, position: INPoint? = nil, color: UIColor? = nil) {
        self.init(withMap: map)
        self.position = position ?? .zero
        self.color = color ?? .black
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, position: INPoint) {
        self.init(withMap: map, position: position)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, position: INPoint, color: UIColor) {
        self.init(withMap: map, position: position, color: color)
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Places Circle on the map with all given settings. 'position' should be set before `draw()` to indicate where Circle should to be located.
    /// Use of this method is indispensable to draw Circle with set configuration in the IndoorNavi Map.
    @objc public func draw() {
        var javaScriptString = String()
        javaScriptString += getSetPositionScript()
        javaScriptString += getApplyColorScript()
        javaScriptString += getSetBorderScript()
        javaScriptString += getSetRadiusScript()
        javaScriptString += String(format: ScriptTemplates.DrawTemplate, javaScriptVariableName)
        ready(javaScriptString)
    }
    
    private func getSetPositionScript() -> String {
        let positionString = PointHelper.pointString(fromCoordinates: position)
        let javaScriptString = String(format: ScriptTemplates.SetPosition, javaScriptVariableName, positionString)
        return javaScriptString
    }
    
    /// Represents position of the Circle in real world. Coordinates needs to be given as real world dimensions that map is representing. To apply this it's necessary to call `draw()` after. Default value is `INPoint.zero`.
    @objc public var position: INPoint = INPoint.zero
    
    private func getSetRadiusScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.SetRadius, javaScriptVariableName, radius)
        return javaScriptString
    }
    
    /// Radius of the Circle. To apply this it's necessary to call `draw()` after. Default value is `5`.
    @objc public var radius: Int = 5
    
    private func getSetBorderScript() -> String {
        let stringColor = ColorHelper.colorString(fromColor: border.color)
        let borderString = String(format: ScriptTemplates.Border, border.width, stringColor)
        let javaScriptString = String(format: ScriptTemplates.SetBorder, javaScriptVariableName, borderString)
        return javaScriptString
    }
    
    /// Border of the Circle. Describes width and color of the border. To apply this it's necessary to call `draw()` after. Default width is `0` and default color is `.black`.
    public var border: Border = Border(width: 0, color: .black)
    
    @available(swift, obsoleted: 1.0)
    @objc public var borderWidth: Int {
        set {
            border.width = newValue
        }
        get {
            return border.width
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public var borderColor: UIColor {
        set {
            border.color = newValue
        }
        get {
            return border.color
        }
    }
    
    /// `INCircles`'s color and opacity. To apply this it's necessary to call `draw()` after. Default value is `.black`.
    @objc public var color: UIColor = .black
    
    private func getApplyColorScript() -> String {
        let javaScriptString = getSetColorScript(withRed: color.rgba.red, green: color.rgba.green, blue: color.rgba.blue) + getSetOpacityScript(withOpacity: color.rgba.alpha)
        return javaScriptString
    }
    
    private func getSetColorScript(withRed red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        let stringColor = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
        let javaScriptString = String(format: ScriptTemplates.SetColor, javaScriptVariableName, stringColor)
        return javaScriptString
    }
    
    private func getSetOpacityScript(withOpacity opacity: CGFloat) -> String {
        let standarizedOpacity = ColorHelper.standarizedOpacity(fromValue: opacity)
        let javaScriptString = String(format: ScriptTemplates.SetOpacity, javaScriptVariableName, standarizedOpacity)
        return javaScriptString
    }
}
