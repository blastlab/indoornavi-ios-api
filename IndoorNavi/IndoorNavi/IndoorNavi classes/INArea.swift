//
//  INArea.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 27.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

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
    
    /**
     *  Initializes a new INArea object inside given INMap object.
     *
     *  - Parameter withMap: An INMap object, in which INArea is going to be created.
     */
    public override init(withMap map: INMap) {
        super.init(withMap: map)
        
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, self.hash)
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        self.map.evaluate(javaScriptString:  javaScriptString)
    }
    
    /**
     *  Place area on the map with all given settings. There is necessary to use `points()` before `draw()` to indicate where area should to be located.
     *  Use of this method is indispensable to draw area with set configuration in the IndoorNavi Map.
     */
    public func draw() {
        let javaScriptString = String(format: ScriptTemplates.DrawTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Locates area at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
     *
     *  - Parameter points: Array of Point's that are describing area in real world dimensions. Coordinates are calculated to the map scale and then displayed. For less than 3 points supplied to this method, Area isn't going to be drawn.
     */
    public func points(_ points: [INCoordinates]) {
        let pointsString = CoordinatesHelper.coordinatesArrayString(fromCoordinatesArray: points)
        map.evaluate(javaScriptString: String(format: ScriptTemplates.PointsDeclaration, pointsString))
        let javaScriptString = String(format: ScriptTemplates.PointsTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Fills Area whit given color. To apply this it's necessary to call `draw()` after. Use of this method is optional.
     *
     *  - Parameters:
     *      - red: The red value of the color. Values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     *      - green: The green value of the color. Values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     *      - blue: The blue value of the color. Values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     */
    public func setFillColor(red: CGFloat, green: CGFloat, blue: CGFloat) {
        let stringColor = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
        let javaScriptString = String(format: ScriptTemplates.SetFillColorTemplate, javaScriptVariableName, stringColor)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Sets Area opacity. To apply this it's necessary to call `draw()` after. Use of this method is optional.
     *
     *  - Parameter opacity: Number between 1.0 and 0. Set it to 1.0 for no opacity, 0 for maximum opacity. Values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     */
    public func setOpacity(_ opacity: CGFloat) {
        let standarizedOpacity = ColorHelper.standarizedOpacity(fromValue: opacity)
        let javaScriptString = String(format: ScriptTemplates.SetOpacityTemplate, javaScriptVariableName, standarizedOpacity)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
