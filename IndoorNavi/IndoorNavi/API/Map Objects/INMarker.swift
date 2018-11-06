//
//  INMarker.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an `INMarker`, creates the `INMarker` object in iframe that communicates with frontend server and places a Marker.
public class INMarker: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "marker%u"
        static let Initialization = "var %@ = new INMarker(navi);"
        static let AddEventListener = "%@.addEventListener(Event.MOUSE.CLICK, () => webkit.messageHandlers.EventCallbacksController.postMessage('%@'));"
        static let RemoveEventListener = "%@.removeEventListener(Event.MOUSE.CLICK);"
        static let Place = "%@.draw();"
        static let SetPosition = "%@.setPosition(%@);"
        static let SetLabel = "%@.setLabel('%@');"
        static let RemoveLabel = "%@.removeLabel();"
        static let Open = "%@.open(%@);"
        static let SetIcon = "%@.setIcon('%@');"
        static let Ready = "%@.ready().then(() => {%@});"
    }
    
    private var callbackUUID: UUID?
    
    /// Initializes a new `INMarker` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which `INMarker` object is going to be created.
    ///   - point:  Represents marker position in real world. Coordinates are calculated to the map scale and then displayed. Position will be clipped to the point in the bottom center of marker icon.
    ///   - iconPath: URL path to icon.
    ///   - labelText: `String` that will be used as a marker label.
    public convenience init(withMap map: INMap, position: INPoint? = nil, iconPath: String? = nil, label: String? = nil) {
        self.init(withMap: map)
        self.iconPath = iconPath
        self.position = position ?? .zero
        self.label = label
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, position: INPoint) {
        self.init(withMap: map, position: position)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, position: INPoint, iconPath: String) {
        self.init(withMap: map, position: position, iconPath: iconPath)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, position: INPoint, iconPath: String, label: String) {
        self.init(withMap: map, position: position, iconPath: iconPath, label: label)
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName)
        map.evaluate(javaScriptString)
    }
    
    private func getAddEventListenerScript() -> String? {
        if let uuid = callbackUUID?.uuidString {
            let javaScriptString = String(format: ScriptTemplates.AddEventListener, self.javaScriptVariableName, uuid)
            return javaScriptString
        }
        
        return nil
    }
    
    /// Adds a block to invoke when the marker is tapped.
    ///
    /// - Parameter onClickCallback: A block to invoke when marker is tapped.
    @objc public func addEventListener(onClickCallback: @escaping () -> Void) {
        callbackUUID = callbackUUID ?? UUID()
        self.map.eventCallbacksController.eventCallbacks[callbackUUID!.uuidString] = onClickCallback
    }
    
    private func getRemoveEventListenerScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.RemoveEventListener, self.javaScriptVariableName)
        return javaScriptString
    }
    
    /// Removes block invoked on tap if exists.
    @objc public func removeEventListener() {
        if let uuid = self.callbackUUID?.uuidString {
            callbackUUID = nil
            self.map.eventCallbacksController.removeEventCallback(forUUID: uuid)
        }
    }
    
    /// Place market on the map with all given settings. There is necessary to use `point()` method before `draw()` to indicate the point where marker should to be located.
    /// Use of this method is indispensable to display marker with set configuration in the IndoorNavi Map.
    @objc public func draw() {
        var javaScriptString = String()
        javaScriptString += iconPath != nil ? getSetIconScript(withPath: iconPath!) : ""
        javaScriptString += getSetPositionScript()
        javaScriptString += getSetLabelScript() ?? ""
        javaScriptString += getAddEventListenerScript() ?? getRemoveEventListenerScript()
        javaScriptString += String(format: ScriptTemplates.Place, self.javaScriptVariableName)
        ready(javaScriptString)
    }
    
    /// Represents position of the marker in real world. Coordinates needs to be given as real world dimensions that map is representing. Position will be clipped to the point in the bottom center of marker icon. Use of this method is indispensable. Default value is `.zero`.
    @objc public var position = INPoint.zero
    
    private func getSetPositionScript() -> String {
        let pointString = PointHelper.pointString(fromCoordinates: position)
        let javaScriptString = String(format: ScriptTemplates.SetPosition, self.javaScriptVariableName, pointString)
        return javaScriptString
    }
    
    private func getSetLabelScript() -> String? {
        if let label = label {
            let javaScriptString = String(format: ScriptTemplates.SetLabel, self.javaScriptVariableName, label)
            return javaScriptString
        } else {
            let javaScriptString = getRemoveLabelScript()
            return javaScriptString
        }
    }
    
    /// `String` used as a marker label. If no text is set or value is `nil`, label won't be displayed. In order to change label's text, set new value and call `draw()`.
    @objc public var label: String?
    
    private func getRemoveLabelScript() -> String {
        let javaScriptString = String(format: ScriptTemplates.RemoveLabel, self.javaScriptVariableName)
        return javaScriptString
    }
    
    /// Removes marker `label` and sets its to `nil`. To remove label it is indispensable to call `draw()` again.
    @objc public func removeLabel() {
        label = nil
    }
    
    /// Displays `INInfoWindow` on marker.
    ///
    /// - Parameter infoWindow: An `INInfoWindow` object.
    @objc(addInfoWindow:) public func add(infoWindow: INInfoWindow) {
        let readyScript = infoWindow.getSetPropertiesScript() + String(format: ScriptTemplates.Open, infoWindow.javaScriptVariableName, self.javaScriptVariableName)
        let javaScriptString = String(format: ScriptTemplates.Ready, javaScriptVariableName, readyScript)
        infoWindow.ready(javaScriptString)
    }
    
    private func getSetIconScript(withPath path: String) -> String {
        let javaScriptString = String(format: ScriptTemplates.SetIcon, self.javaScriptVariableName, path)
        return javaScriptString
    }
    
    /// Marker's icon. In order to change it, set new value and call `draw()`.
    @objc public var iconPath: String?
}
