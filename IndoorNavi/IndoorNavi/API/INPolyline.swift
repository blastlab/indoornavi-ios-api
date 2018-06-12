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
    
    /**
     *  Initializes a new `INPolyline` object inside given INMap object.
     *
     *  - Parameter withMap: An `INMap` object, in which `INPolyline` object is going to be created.
     */
    public init(withMap map: INMap) {
        super.init(withMap: map, variableNameTemplate: ScriptTemplates.VariableName)
        
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        self.map.evaluate(javaScriptString:  javaScriptString)
    }
    
    /**
     *  Locates polyline at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
     *
     *  - Parameter points: Array of `Point`'s that are describing polyline in real world dimensions. Coordinates are calculated to the map scale and then displayed.
     */
    public func points(_ points: [Point]) {
        ready {
            let pointsString = PointHelper.coordinatesArrayString(fromCoordinatesArray: points)
            self.map.evaluate(javaScriptString: String(format: ScriptTemplates.PointsDeclaration, pointsString))
            let javaScriptString = String(format: ScriptTemplates.PointsTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Place polyline on the map with all given settings.
     *  There is necessary to use `points()` before `draw()` to indicate where polyline should to be located.
     *  Use of this method is indispensable to draw polyline with set configuration.
     */
    public func draw() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.DrawTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Sets polyline lines and points color.
     *
     *  - Parameters:
     *      - red: The red value of the color. Values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     *      - green: The green value of the color. Values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     *      - blue: The blue value of the color. Values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     */
    public func set(red: CGFloat, green: CGFloat, blue: CGFloat) {
        ready {
            let stringColor = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
            let javaScriptString = String(format: ScriptTemplates.SetLineColorTemplate, self.javaScriptVariableName, stringColor)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
 }
