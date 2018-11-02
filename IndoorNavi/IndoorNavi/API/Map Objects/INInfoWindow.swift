//
//  INInfoWindow.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 02.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an info window, creates an `INInfoWindow` object in iframe that communicates with frontend server and adds info window to a given `INObject` child.
public class INInfoWindow: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "infoWindow%u"
        static let Initialization = "var %@ = new INInfoWindow(navi);"
        static let SetHeight = "%@.setHeight(%i);"
        static let SetWidth = "%@.setWidth(%i);"
        static let SetContent = "%@.setContent('%@');"
        static let SetPosition = "%@.setPositionAt(%i);"
    }
    
     /// Position regarding to related `INObject` object.
     ///
     /// - top: Top side position in regard to related object.
     /// - right: Right side position in regard to related object.
     /// - bottom: Bottom side position in regard to related object.
     /// - left: Left side position in regard to related object.
     /// - topRight: Top-right side position in regard to related object.
     /// - topLeft: Top-left side position in regard to related object.
     /// - bottomRight: Bottom-right side position in regard to related object.
     /// - bottomLeft: Bottom-left side position in regard to related object.
    @objc public enum Position: Int {
        case top
        case right
        case bottom
        case left
        case topRight
        case topLeft
        case bottomRight
        case bottomLeft
    }
    
    /// Initializes a new `INInfoWindow` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which `INArea` is going to be created.
    ///   - width: Width dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    ///   - height: Height dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    ///   - position: Position of info window regarding to object that info window will be appended to. Default position for info window is `.top`.
    ///   - innerHTML: Text or HTML template in string format that will be passed to info window as text.
    public convenience init(withMap map: INMap, width: Int? = nil, height: Int? = nil, position: Position? = nil, content: String? = nil) {
        self.init(withMap: map)
        self.width = width ?? 250
        self.height = height ?? 250
        self.position = position ?? .top
        self.content = content
    }
    
    func getSetPropertiesScript() -> String {
        var javaScriptString = String()
        javaScriptString += getSetPositionScript()
        javaScriptString += getSetContentScript()
        javaScriptString += getSetWidthScript()
        javaScriptString += getSetHeightScript()
        return javaScriptString
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, width: Int, height: Int) {
        self.init(withMap: map, width: width, height: height)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, width: Int, height: Int, position: Position) {
        self.init(withMap: map, width: width, height: height, position: position)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, width: Int, height: Int, position: Position, content: String) {
        self.init(withMap: map, width: width, height: height, position: position, content: content)
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName)
        map.evaluate(javaScriptString)
    }
    
    private func getSetHeightScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.SetHeight, self.javaScriptVariableName, height > 50 ? height : 50)
        return javaScriptString
    }
    
    /// Height dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    @objc public var height: Int = 250
    
    private func getSetWidthScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.SetWidth, self.javaScriptVariableName, width > 50 ? width : 50)
        return javaScriptString
    }
    
    /// Width dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    @objc public var width: Int = 250
    
    /// Text or HTML template in string format that is displayed in InfoWindow. To reset label to a new content set this property to a new value and call `draw()`.
    @objc public var content: String?
    
    private func getSetContentScript() -> String {
        let contentString = content ?? ""
        let javaScriptString = String(format: ScriptTemplates.SetContent, self.javaScriptVariableName, contentString)
        return javaScriptString
    }
    
    /// Position of info window regarding to object that info window will be appended to. Default position for info window is `.top`.
    @objc public var position: Position = .top
    
    private func getSetPositionScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.SetPosition, self.javaScriptVariableName, self.position.rawValue)
        return javaScriptString
    }
}
