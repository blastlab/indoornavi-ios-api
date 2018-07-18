//
//  Polyline.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 17.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing a `INPolyline`, communicates with indoornavi frontend server and draws `INPolyline`.
public class INPolyline: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "poly%u"
        static let InitializationTemplate = "var %@ = new INPolyline(navi);"
        static let PointsTemplate = "%@.points(points);"
        static let DrawTemplate = "%@.draw();"
        static let SetLineColorTemplate = "%@.setLineColor('%@')"
        static let PointsDeclaration = "var points = %@;"
    }
    
    /// Initializes a new `INPolyline` object inside given INMap object.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which `INPolyline` object is going to be created.
    ///   - points: Array of `Point`'s that are describing polyline in real world dimensions. Coordinates are calculated to the map scale and then displayed.
    ///   - color: Polyline's lines and points color.
    public convenience init(withMap map: INMap, points: [INPoint]? = nil, color: UIColor? = nil) {
        self.init(withMap: map)
        if let points = points {
            set(points: points)
        }
        if let color = color {
            set(color: color)
        }
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
        self.map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Locates polyline at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
    ///
    /// - Parameter points: Array of `Point`'s that are describing polyline in real world dimensions. Coordinates are calculated to the map scale and then displayed.
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
        let points = PointHelper.pointsArray(fromCArray: pointsArray, withSize: size)
        set(points: points)
    }
    
    /// Place polyline on the map with all given settings.
    /// There is necessary to use `points()` before `draw()` to indicate where polyline should to be located.
    /// Use of this method is indispensable to draw polyline with set configuration.
    @objc public func draw() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.DrawTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Sets lines and points color. `INPolyline` cannot be opaque, so color's opacity parameter is omitted.
    ///
    /// - Parameter color: Polyline's color.
    public func set(color: UIColor) {
        setColorInJavaScript(color: color)
    }
    
    private func setColorInJavaScript(color: UIColor) {
        if let colorComponents = color.cgColor.components {
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            ready {
                let stringColor = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
                let javaScriptString = String(format: ScriptTemplates.SetLineColorTemplate, self.javaScriptVariableName, stringColor)
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
}
