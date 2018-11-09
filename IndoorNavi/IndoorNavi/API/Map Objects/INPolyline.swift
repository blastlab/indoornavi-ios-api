//
//  Polyline.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 17.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an `INPolyline`, communicates with indoornavi frontend server and draws Polyline.
public class INPolyline: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "poly%u"
        static let Initialization = "var %@ = new INPolyline(navi);"
        static let SetPoints = "%@.setPoints(points);"
        static let Draw = "%@.draw();"
        static let SetLineColor = "%@.setColor('%@');"
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
        self.points = points ?? [INPoint]()
        self.color = color ?? .black
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
        self.map.evaluate(javaScriptString)
    }
    
    /// Locates polyline at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
    ///
    /// - Parameter points: Array of `Point`'s that are describing polyline in real world dimensions. Coordinates are calculated to the map scale and then displayed.
    public var points = [INPoint]()
    
    private func getSetPointsScript() -> String {
        let pointsString = PointHelper.pointsString(fromCoordinatesArray: points)
        let javaScriptString = String(format: ScriptTemplates.PointsDeclaration, pointsString) + String(format: ScriptTemplates.SetPoints, self.javaScriptVariableName)
        return javaScriptString
    }
    
    @available(swift, obsoleted: 1.0)
    @objc(setPointsArray:withArraySize:) public func set(pointsArray: UnsafePointer<INPoint>, withArraySize size:Int) {
        points = PointHelper.pointsArray(fromCArray: pointsArray, withSize: size)
    }
    
    /// Place polyline on the map with all given settings.
    /// There is necessary to use `points()` before `draw()` to indicate where polyline should to be located.
    /// Use of this method is indispensable to draw polyline with set configuration.
    @objc public func draw(completionHandler: ((Error?) -> Void)? = nil) {
        var javaScriptString = String()
        javaScriptString += getSetPointsScript()
        javaScriptString += getColorScript()
        javaScriptString += String(format: ScriptTemplates.Draw, self.javaScriptVariableName)
        ready(javaScriptString)
    }
    
    /// `INPolyline`'s color. To apply this it's necessary to call `draw()` after. It cannot be opaque, so color's opacity parameter is omitted. Default value is `.black`.
    @objc public var color: UIColor = .black
    
    private func getColorScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.SetLineColor, self.javaScriptVariableName, color.colorString)
        return javaScriptString
    }
}
