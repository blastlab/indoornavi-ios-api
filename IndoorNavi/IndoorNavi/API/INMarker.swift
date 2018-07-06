//
//  INMarker.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an `INMarker`, creates the `INMarker` object in iframe that communicates with frontend server and places a marker.
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
    /// - Parameter map: An `INMap` object, in which `INMarker` object is going to be created.
    @objc public override init(withMap map: INMap) {
        super.init(withMap: map)
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Adds a block to be invoked when the marker is tapped.
    ///
    /// - Parameter onClickCallback: A block to invoke when marker is tapped.
    @objc public func addEventListener(onClickCallback: @escaping () -> Void) {
        ready {
            self.callbackUUID = UUID().uuidString
            self.map.eventCallbacksController.eventCallbacks[self.callbackUUID!] = onClickCallback
            
            let javaScriptString = String(format: ScriptTemplates.AddEventListenerTemplate, self.javaScriptVariableName, self.callbackUUID!)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Removes block invoked on tap if exists. Use of this method is optional.
    @objc public func removeEventListener() {
        ready {
            if let uuid = self.callbackUUID {
                self.map.eventCallbacksController.removeEventCallback(forUUID: uuid)
                let javaScriptString = String(format: ScriptTemplates.RemoveEventListenerTemplate, self.javaScriptVariableName)
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /// Place market on the map with all given settings. There is necessary to use `point()` method before `draw()` to indicate the point where marker should to be located.
    /// Use of this method is indispensable to display marker with set configuration in the IndoorNavi Map.
    @objc public func draw() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.PlaceTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
     /// Locates marker at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
     ///
     /// - Parameter point: Represents marker position in real world. Coordinates are calculated to the map scale and then displayed. Position will be clipped to the point in the bottom center of marker icon.
    @objc(setPoint:) public func set(point: INPoint) {
        ready {
            let pointString = PointHelper.coordinatesString(fromCoordinates: point)
            let javaScriptString = String(format: ScriptTemplates.PointTemplate, self.javaScriptVariableName, pointString)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Sets marker label. Use of this method is optional. If no text is set, label won't be displayed. In order to change label's text, call this method again passing new label as a string and call `draw()`.
    ///
    /// - Parameter text: `String` that will be used as a marker label.
    @objc public func setLabel(withText text: String) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.SetLabelTemplate, self.javaScriptVariableName, text)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Removes marker label. To remove label it is indispensable to call `draw()` again.
    @objc public func removeLabel() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.RemoveLabelTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Displays `INInfoWindow` on marker.
    ///
    /// - Parameter infoWindow: An `INInfoWindow` object.
    @objc(addInfoWindow:) public func add(infoWindow: INInfoWindow) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.OpenTemplate, infoWindow.javaScriptVariableName, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Sets marker icon. To apply this method it's necessary to call `draw()` after. Use of this method is optional.
    ///
    /// - Parameter path: URL path to icon.
    @objc public func setIcon(withPath path: String) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.SetIconTemplate, self.javaScriptVariableName, path)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
