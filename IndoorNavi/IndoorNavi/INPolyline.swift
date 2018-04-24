//
//  Polyline.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 17.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

/// Class representing a INPolyline, creates the INPolyline in webView, communicates with indoornavi frontend server and draws INPolyline.
public class INPolyline: INObject {
    
    /**
     *  Initializes a new Polyline object inside given INMap object.
     *
     *  - Parameter withMap: An INMap object, in which Polyline is going to be created.
     */
    public override init(withMap map: INMap) {
        super.init(withMap: map)
        
        print("Hash = \(self.hash)")
        javaScriptVariableName = String(format: Constants.polylineVariableName, self.hash)
        let javaScriptString = String(format: Constants.polylineInitializationTemplate, javaScriptVariableName)
        self.map.evaluate(javaScriptString:  javaScriptString)
    }
    
    /**
     *  Locates polyline at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
     *
     *  - Parameter points: Array of Point's that are describing polyline in real world dimensions. Coordinates are calculated to the map scale and then displayed.
     */
    public func points(_ points: [INCoordinates]) {
        let pointsString = CoordinatesHelper.coordinatesArrayString(fromCoordinatesArray: points)
        let javaScriptString = String(format: Constants.polylinePointTemplate, javaScriptVariableName, pointsString)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Place polyline on the map with all given settings.
     *  There is necessary to use points() method before place() method to indicate where polyline should to be located.
     *  Use of this method is indispensable to draw polyline with set configuration.
     */
    public func draw() {
        let javaScriptString = String(format: Constants.polylinePlaceTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Sets polyline lines and points color.
     *
     *  - Parameter lineColor: Specifies line color.
     */
    public func set(lineColor color: UIColor) {
        let stringColor = colorString(fromColor: color)
        let javaScriptString = String(format: Constants.polylineSetLineColorTemplate, javaScriptVariableName, stringColor)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    private func colorString(fromColor color: UIColor) -> String {
        if let colorComponents = color.cgColor.components {
            let red = Int(colorComponents[0]*255)
            let green = Int(colorComponents[1]*255)
            let blue = Int(colorComponents[2]*255)
            
            let stringColor = String(format: "rgb(%d,%d,%d)", red, green, blue)
            return stringColor
        } else {
            return String(format: "%02X%02X%02X", 0, 0, 0)
        }
    }
 }
