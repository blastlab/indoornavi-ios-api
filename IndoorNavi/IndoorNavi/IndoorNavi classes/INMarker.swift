//
//  INMarker.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing a Marker, creates the INMarker object in iframe that communicates with frontend server and places a marker.
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
     *  Initializes a new INMarker object inside given INMap object.
     *
     *  - Parameter withMap: An INMap object, in which INMarker object is going to be created.
     */
    public override init(withMap map: INMap) {
        super.init(withMap: map)
        
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, self.hash)
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        self.map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Adds a block to be invoked when the marker is tapped.
     *
     *  - Parameter onClickCallback: A block to invoke when marker is tapped.
     */
    public func addEventListener(onClickCallback: @escaping () -> Void) {
        callbackUUID = UUID().uuidString
        map.eventCallbacksController.eventCallbacks[callbackUUID!] = onClickCallback
        
        let javaScriptString = String(format: ScriptTemplates.AddEventListenerTemplate, javaScriptVariableName, callbackUUID!)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Removes block invoked on tap if exists. Use of this method is optional.
     */
    public func removeEventListener() {
        if let uuid = callbackUUID {
            map.eventCallbacksController.removeEventCallback(forUUID: uuid)
            let javaScriptString = String(format: ScriptTemplates.RemoveEventListenerTemplate, javaScriptVariableName)
            map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Place market on the map with all given settings. There is necessary to use `point()` method before `draw()` to indicate the point where marker should to be located.
     *  Use of this method is indispensable to display marker with set configuration in the IndoorNavi Map.
     */
    public func draw() {
        let javaScriptString = String(format: ScriptTemplates.PlaceTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Locates marker at given coordinates. Coordinates needs to be given as real world dimensions that map is representing. Use of this method is indispensable.
     *
     *  - Parameter point: Represents marker position in real world. Coordinates are calculated to the map scale and then displayed. Position will be clipped to the point in the bottom center of marker icon.
     */
    public func point(_ point: INCoordinates) {
        let pointString = CoordinatesHelper.coordinatesString(fromCoordinates: point)
        let javaScriptString = String(format: ScriptTemplates.PointTemplate, javaScriptVariableName, pointString)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Sets marker label. Use of this method is optional. If no text is set, label won't be displayed. In order to change label's text, call this method again passing new label as a string and call `draw()`.
     *
     *  - Parameter withText: `String` that will be used as a marker label.
     */
    public func setLabel(withText text: String) {
        let javaScriptString = String(format: ScriptTemplates.SetLabelTemplate, javaScriptVariableName, text)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Removes marker label. To remove label it is indispensable to call `draw()` again.
     */
    public func removeLabel() {
        let javaScriptString = String(format: ScriptTemplates.RemoveLabelTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Sets marker icon. To apply this method it's necessary to call `draw()` after. Use of this method is optional.
     *
     *  - Parameter path: URL path to icon.
     */
    public func setIcon(withPath path: String) {
        let javaScriptString = String(format: ScriptTemplates.SetIconTemplate, javaScriptVariableName, path)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
