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
        static let SetFillColor = "%@.setColor('%@');"
        static let SetOpacity = "%@.setOpacity('%f');"
        static let PointsDeclaration = "var points = %@;"
        static let Remove = "%@.remove();"
        static let IsWithin = "%@.isWithin(%@);"
        static let AddEventListener = "%@.addEventListener(Event.MOUSE.CLICK, () => webkit.messageHandlers.EventCallbacksController.postMessage('%@'));"
        static let RemoveEventListener = "%@.removeEventListener(Event.MOUSE.CLICK);"
        static let SetBorder = "%@.setBorder(%@);"
        static let Border = "new Border(%d, '%@')"
    }
    
    private var callbackUUID: UUID?
    
    /// Initializes a new `INArea` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map:  An `INMap` object, in which `INArea` is going to be created.
    ///   - points: Array of Point's that are describing area in real world dimensions. Coordinates are calculated to the map scale and then displayed. For less than 3 points supplied to this method, Area isn't going to be drawn.
    ///   - color: Area's fill color and opacity.
    public convenience init(withMap map: INMap, points: [INPoint]? = nil, color: UIColor? = nil) {
        self.init(withMap: map)
        self.points = points ?? [INPoint]()
        self.color = color ?? .black
    }
    
    convenience init?(withMap map: INMap, fromJSONObject jsonObject: Any?) {
        
        if let dictionary = jsonObject as? [String: Any], let scale = map.scale {
            let points = PointHelper.points(fromJSONObject: dictionary["points"])
            
            guard points.count > 2 else {
                return nil
            }
            
            let pointsInRealDimensions = MapHelper.realCoordinatesArray(fromPixelArray: points, scale: scale)
            let defaultColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3)
            self.init(withMap: map, points: pointsInRealDimensions, color: defaultColor)
            databaseID = dictionary["id"] as? Int
            return
        }
        
        assertionFailure("Could not initialize INArea from JSON object.")
        return nil
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
    
    /// ID of the object in database. It uniquely identifies `INArea` downloaded from backend. This value is optional, area's created locally does not have ID in database, so this value is `nil` for them.
    private(set) public var databaseID: Int?
    
    /// Place Area on the map with all given settings. There is necessary to use `points()` before `draw()` to indicate where area should to be located.
    /// Use of this method is indispensable to draw area with set configuration in the IndoorNavi Map.
    @objc public func draw() {
        var javaScriptString = String()
        javaScriptString += getSetPointsScript()
        javaScriptString += getAppplyColorScript()
        javaScriptString += getSetBorderScript()
        javaScriptString += getAddEventListenerScript() ?? getRemoveEventListener()
        javaScriptString += String(format: ScriptTemplates.Draw, self.javaScriptVariableName)
        ready(javaScriptString)
    }
    
    /// Array of Point's that is describing area in real world dimensions. Coordinates needs to be given as real world dimensions that map is representing. For less than 3 points supplied to this method, Area isn't going to be drawn. Use of this method is indispensable.
    public var points = [INPoint]()
    
    private func getSetPointsScript() -> String {
        let pointsString = PointHelper.pointsString(fromCoordinatesArray: points)
        let javaScriptString = String(format: ScriptTemplates.PointsDeclaration, pointsString) + String(format: ScriptTemplates.SetPoints, self.javaScriptVariableName)
        return javaScriptString
    }
    
    @available(swift, obsoleted: 1.0)
    @objc(setPointsArray:withArraySize:) public func set(pointsArray: UnsafePointer<INPoint>, withArraySize size:Int) {
        self.points = PointHelper.pointsArray(fromCArray: pointsArray, withSize: size)
    }
    
    /// `INArea`'s fill color and opacity. To apply this it's necessary to call `draw()` after. Default value is `.black`.
    @objc public var color: UIColor = .black
    
    /// Checks if point of given coordinates is inside area. Use of this method is optional.
    ///
    /// - Parameters:
    ///   - coordinates: Coordinates that are described in real world dimensions. Coordinates are calculated to the map scale.
    ///   - callbackHandler: A block to invoke when the boolean is available.
    public func isWithin(coordinates: INPoint, callbackHandler: @escaping (Bool?) -> Void) {
        let coordinatesString = PointHelper.pointString(fromCoordinates: coordinates)
        let javaScriptString = String(format: ScriptTemplates.IsWithin, self.javaScriptVariableName, coordinatesString)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString) { response, error in
                
                guard let isWithPoint = response as? Bool, error == nil else {
                    assert(error == nil, "An error occured while performing isWithin method: \(error!.localizedDescription).")
                    assertionFailure("Could not retrieve response while performing isWithin method.")
                    callbackHandler(nil)
                    return
                }
                
                callbackHandler(isWithPoint)
            }
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public func isWithin(coordinates: INPoint, callbackHandler: @escaping (Bool) -> Void)  {
        let callback: (Bool?) -> Void = { isWithin in
            if let isWithin = isWithin {
                callbackHandler(isWithin)
            } else {
                callbackHandler(false)
            }
        }
        
        isWithin(coordinates: coordinates, callbackHandler: callback)
    }
    
    private func getAddEventListenerScript() -> String? {
        if let uuid = callbackUUID?.uuidString {
            let javaScriptString = String(format: ScriptTemplates.AddEventListener, self.javaScriptVariableName, uuid)
            return javaScriptString
        }
        
        return nil
    }
    
    /// Adds a block to invoke when the area is tapped. To apply this it's necessary to call `draw()` after.
    ///
    /// - Parameter onClickCallback: A block to invoke when area is tapped.
    @objc public func addEventListener(onClickCallback: @escaping () -> Void) {
        self.callbackUUID = UUID()
        self.map.eventCallbacksController.eventCallbacks[self.callbackUUID!.uuidString] = onClickCallback
    }
    
    private func getRemoveEventListener() -> String {
        let javaScriptString = String(format: ScriptTemplates.RemoveEventListener, self.javaScriptVariableName)
        return javaScriptString
    }
    
    /// Removes block invoked on tap if exists. Use of this method is optional.
    @objc public func removeEventListener() {
        if let uuid = self.callbackUUID?.uuidString {
            callbackUUID = nil
            self.map.eventCallbacksController.removeEventCallback(forUUID: uuid)
        }
    }
    
    /// Geometric center of the `INArea` in centimeters.
    public var center: INPoint {
        let x = points.map({ $0.x }).reduce(0, +) / Int32(points.count)
        let y = points.map({ $0.y }).reduce(0, +) / Int32(points.count)
        let centerPoint = INPoint(x: x, y: y)
        return centerPoint
    }
    
    private func getSetBorderScript() -> String {
        let stringColor = ColorHelper.colorString(fromColor: border.color)
        let borderString = String(format: ScriptTemplates.Border, border.width, stringColor)
        let javaScriptString = String(format: ScriptTemplates.SetBorder, javaScriptVariableName, borderString)
        return javaScriptString
    }
    
    /// Border of the Area. Describes width and color of the border. To apply this it's necessary to call `draw()` after. Default width is `0` and default color is `.black`.
    public var border: Border = Border(width: 0, color: .black)
    
    private func getAppplyColorScript() -> String {
        let javaScriptString = getSetColorScript(withRed: color.rgba.red, green: color.rgba.green, blue: color.rgba.blue) + getSetOpacityScript(opacity: color.rgba.alpha)
        return javaScriptString
    }
    
    private func getSetColorScript(withRed red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        let stringColor = ColorHelper.colorStringFromColorComponents(red: red, green: green, blue: blue)
        let javaScriptString = String(format: ScriptTemplates.SetFillColor, self.javaScriptVariableName, stringColor)
        return javaScriptString
    }
    
    private func getSetOpacityScript(opacity: CGFloat) -> String {
        let standarizedOpacity = ColorHelper.standarizedOpacity(fromValue: opacity)
        let javaScriptString = String(format: ScriptTemplates.SetOpacity, self.javaScriptVariableName, standarizedOpacity)
        return javaScriptString
    }
}
