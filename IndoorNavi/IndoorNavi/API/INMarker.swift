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
        static let SetIconTemplate = "%@.setIcon('%@');"
    }
    
    private var callbackUUID: String?
    
    /**
     *  Initializes a new `INMarker` object inside given `INMap` object.
     *
     *  - Parameter withMap: An `INMap` object, in which `INMarker` object is going to be created.
     */
    public init(withMap map: INMap) {
        super.init(withMap: map, variableNameTemplate: ScriptTemplates.VariableName)
    }
    
    override func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Adds a block to be invoked when the marker is tapped.
     *
     *  - Parameter onClickCallback: A block to invoke when marker is tapped.
     */
    public func addEventListener(onClickCallback: @escaping () -> Void) {
        ready {
            self.callbackUUID = UUID().uuidString
            self.map.eventCallbacksController.eventCallbacks[self.callbackUUID!] = onClickCallback
            
            let javaScriptString = String(format: ScriptTemplates.AddEventListenerTemplate, self.javaScriptVariableName, self.callbackUUID!)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Removes block invoked on tap if exists. Use of this method is optional.
     */
    public func removeEventListener() {
        ready {
            if let uuid = self.callbackUUID {
                self.map.eventCallbacksController.removeEventCallback(forUUID: uuid)
                let javaScriptString = String(format: ScriptTemplates.RemoveEventListenerTemplate, self.javaScriptVariableName)
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /**
     *  Place market on the map with all given settings. There is necessary to use `point()` method before `draw()` to indicate the point where marker should to be located.
     *  Use of this method is indispensable to display marker with set configuration in the IndoorNavi Map.
     */
    public func draw() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.PlaceTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Locates marker at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
     *
     *  - Parameter point: Represents marker position in real world. Coordinates are calculated to the map scale and then displayed. Position will be clipped to the point in the bottom center of marker icon.
     */
    public func point(_ point: Point) {
        ready {
            let pointString = PointHelper.coordinatesString(fromCoordinates: point)
            let javaScriptString = String(format: ScriptTemplates.PointTemplate, self.javaScriptVariableName, pointString)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Sets marker label. Use of this method is optional. If no text is set, label won't be displayed. In order to change label's text, call this method again passing new label as a string and call `draw()`.
     *
     *  - Parameter withText: `String` that will be used as a marker label.
     */
    public func setLabel(withText text: String) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.SetLabelTemplate, self.javaScriptVariableName, text)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Removes marker label. To remove label it is indispensable to call `draw()` again.
     */
    public func removeLabel() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.RemoveLabelTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Sets marker icon. To apply this method it's necessary to call `draw()` after. Use of this method is optional.
     *
     *  - Parameter path: URL path to icon.
     */
    public func setIcon(withPath path: String) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.SetIconTemplate, self.javaScriptVariableName, path)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
