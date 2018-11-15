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
    }
    
    /// Initializes a new `INCircle` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map:  An `INMap` object, in which `INCircle` is going to be created.
    ///   - position: Point describing Circle's position in real world dimensions. Coordinates are calculated to the map scale and then displayed.
    ///   - color: Circles's fill color and opacity.
    @objc public convenience init(withMap map: INMap, position: INPoint = .zero, color: UIColor = .black) {
        self.init(withMap: map)
        self.position = position
        self.color = color
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName)
        map.evaluate(javaScriptString)
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
        let javaScriptString = String(format: ScriptTemplates.SetBorder, javaScriptVariableName, border.borderScript)
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
        let javaScriptString = getSetColorScript() + getSetOpacityScript()
        return javaScriptString
    }
    
    private func getSetColorScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.SetColor, javaScriptVariableName, color.colorString)
        return javaScriptString
    }
    
    private func getSetOpacityScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.SetOpacity, javaScriptVariableName, color.standarizedOpacity)
        return javaScriptString
    }
}
