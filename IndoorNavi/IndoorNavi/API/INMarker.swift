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
        static let InitializationTemplate = "var %@ = new INMarker(navi);"
        static let AddEventListenerTemplate = "%@.addEventListener(Event.MOUSE.CLICK, () => webkit.messageHandlers.EventCallbacksController.postMessage('%@'));"
        static let RemoveEventListenerTemplate = "%@.removeEventListener(Event.MOUSE.CLICK);"
        static let PlaceTemplate = "%@.draw();"
        static let PointTemplate = "%@.point(%@);"
        static let SetLabelTemplate = "%@.setLabel('%@');"
        static let RemoveLabelTemplate = "%@.removeLabel();"
        static let OpenTemplate = "%@.open(%@);"
        static let SetIconTemplate = "%@.setIcon('%@');"
    }
    
    private var callbackUUID: String?
    
    /// Initializes a new `INMarker` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which `INMarker` object is going to be created.
    ///   - point:  Represents marker position in real world. Coordinates are calculated to the map scale and then displayed. Position will be clipped to the point in the bottom center of marker icon.
    ///   - iconPath: URL path to icon.
    ///   - labelText: `String` that will be used as a marker label.
    public convenience init(withMap map: INMap, point: INPoint? = nil, iconPath: String? = nil, labelText: String? = nil) {
        self.init(withMap: map)
        if let point = point {
            set(point: point)
        }
        if let iconPath = iconPath {
            setIcon(withPath: iconPath)
        }
        if let labelText = labelText {
            setLabel(withText: labelText)
        }
        draw()
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, point: INPoint) {
        self.init(withMap: map, point: point)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, point: INPoint, iconPath: String) {
        self.init(withMap: map, point: point, iconPath: iconPath)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, point: INPoint, iconPath: String, labelText: String) {
        self.init(withMap: map, point: point, iconPath: iconPath, labelText: labelText)
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Adds a block to invoke when the marker is tapped.
    ///
    /// - Parameter onClickCallback: A block to invoke when marker is tapped.
    @objc public func addEventListener(onClickCallback: @escaping () -> Void) {
        callbackUUID = UUID().uuidString
        map.eventCallbacksController.eventCallbacks[self.callbackUUID!] = onClickCallback
        let javaScriptString = String(format: ScriptTemplates.AddEventListenerTemplate, javaScriptVariableName, callbackUUID!)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Removes block invoked on tap if exists. Use of this method is optional.
    @objc public func removeEventListener() {
        if let uuid = self.callbackUUID {
            self.map.eventCallbacksController.removeEventCallback(forUUID: uuid)
            let javaScriptString = String(format: ScriptTemplates.RemoveEventListenerTemplate, javaScriptVariableName)
            ready {
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /// Place market on the map with all given settings. There is necessary to use `point()` method before `draw()` to indicate the point where marker should to be located.
    /// Use of this method is indispensable to display marker with set configuration in the IndoorNavi Map.
    @objc public func draw() {
        let javaScriptString = String(format: ScriptTemplates.PlaceTemplate, javaScriptVariableName)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Locates marker at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
    ///
    /// - Parameter point: Represents position of the marker in real world. Coordinates are calculated to the map scale and then displayed. Position will be clipped to the point in the bottom center of marker icon.
    @objc(setPoint:) public func set(point: INPoint) {
        let pointString = PointHelper.pointString(fromCoordinates: point)
        let javaScriptString = String(format: ScriptTemplates.PointTemplate, javaScriptVariableName, pointString)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Sets marker label. Use of this method is optional. If no text is set, label won't be displayed. In order to change label's text, call this method again passing new label as a string and call `draw()`.
    ///
    /// - Parameter text: `String` that will be used as a marker label.
    @objc public func setLabel(withText text: String) {
        let javaScriptString = String(format: ScriptTemplates.SetLabelTemplate, javaScriptVariableName, text)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Removes marker label. To remove label it is indispensable to call `draw()` again.
    @objc public func removeLabel() {
        let javaScriptString = String(format: ScriptTemplates.RemoveLabelTemplate, javaScriptVariableName)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Displays `INInfoWindow` on marker.
    ///
    /// - Parameter infoWindow: An `INInfoWindow` object.
    @objc(addInfoWindow:) public func add(infoWindow: INInfoWindow) {
        let javaScriptString = String(format: ScriptTemplates.OpenTemplate, infoWindow.javaScriptVariableName, javaScriptVariableName)
        infoWindow.ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Sets marker icon. To apply this method it's necessary to call `draw()` after. Use of this method is optional.
    ///
    /// - Parameter path: URL path to icon.
    @objc public func setIcon(withPath path: String) {
        let javaScriptString = String(format: ScriptTemplates.SetIconTemplate, javaScriptVariableName, path)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
