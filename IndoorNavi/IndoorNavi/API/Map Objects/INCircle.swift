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
    
    public struct Border {
        public var width: Int
        public var color: UIColor
        
        public init(width: Int, color: UIColor) {
            self.width = width
            self.color = color
        }
    }
    
    /// Initializes a new `INCircle` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map:  An `INMap` object, in which `INCircle` is going to be created.
    ///   - position: Point describing Circle's position in real world dimensions. Coordinates are calculated to the map scale and then displayed.
    ///   - color: Circles's fill color and opacity.
    public convenience init(withMap map: INMap, position: INPoint? = nil, color: UIColor? = nil) {
        self.init(withMap: map)
        if let position = position {
            set(position: position)
        }
        if let color = color {
            self.color = color
            applyColorInJavaScript()
        }
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
        let javaScriptString = String(format: ScriptTemplates.DrawTemplate, javaScriptVariableName)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Locates Circle at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
    /// Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
    ///
    /// - Parameter position: Represents position of the Circle in real world. Coordinates are calculated to the map scale and then displayed. Position will be clipped to the point in the bottom center of marker icon.
    @objc(setPoint:) public func set(position: INPoint) {
        let positionString = PointHelper.pointString(fromCoordinates: position)
        let javaScriptString = String(format: ScriptTemplates.SetPosition, javaScriptVariableName, positionString)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Represents position of the Circle in real world. Coordinates needs to be given as real world dimensions that map is representing. To apply this it's necessary to call `draw()` after. Default value is `INPoint.zero`.
    @objc public var position: INPoint = INPoint.zero {
        didSet {
            let positionString = PointHelper.pointString(fromCoordinates: position)
            let javaScriptString = String(format: ScriptTemplates.SetPosition, javaScriptVariableName, positionString)
            ready {
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /// Radius of the Circle. To apply this it's necessary to call `draw()` after. Default value is `5`.
    @objc public var radius: Int = 5 {
        didSet {
            let javaScriptString = String(format: ScriptTemplates.SetRadius, javaScriptVariableName, radius)
            ready {
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /// Border of the Circle. Describes width and color of the border. To apply this it's necessary to call `draw()` after. Default width is `0` and default color is `.black`.
    public var border: Border = Border(width: 0, color: .black) {
        didSet {
            if let stringColor = ColorHelper.colorString(fromColor: border.color) {
                let borderString = String(format: ScriptTemplates.Border, border.width, stringColor)
                let javaScriptString = String(format: ScriptTemplates.SetBorder, javaScriptVariableName, borderString)
                ready {
                    self.map.evaluate(javaScriptString: javaScriptString)
                }
            }
        }
    }
    
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
        let javaScriptString = String(format: ScriptTemplates.SetColor, javaScriptVariableName, stringColor)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    private func setOpacityInJavaScript(opacity: CGFloat) {
        let standarizedOpacity = ColorHelper.standarizedOpacity(fromValue: opacity)
        let javaScriptString = String(format: ScriptTemplates.SetOpacity, javaScriptVariableName, standarizedOpacity)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
