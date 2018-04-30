//
//  INMarker.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

/// Class representing a Marker, creates the INMarker object in iframe that communicates with frontend server and places a marker.
public class INMarker: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "marker%u"
        static let InitializationTemplate = "var %@ = new INMarker(navi);"
        static let AddEventListenerTemplate = "%@.addEventListener(Event.MOUSE.CLICK, () => webkit.messageHandlers.iOS.postMessage('%@'));"
        static let RemoveEventListenerTemplate = "%@.removeEventListener(Event.MOUSE.CLICK);"
        static let PlaceTemplate = "%@.draw();"
        static let PointTemplate = "%@.point(%@);"
        static let SetLabelTemplate = "%@.setLabel('%@');"
        static let RemoveLabelTemplate = "%@.removeLabel();"
        static let SetIconTemplate = "%@.setIcon('%@');"
    }
    
    var callbackUUID: String?
    
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
    
    public func addEventListener(onClickCallback: @escaping () -> Void) {
        callbackUUID = UUID().uuidString
        ClousureManager.eventCallbacks[callbackUUID!] = onClickCallback
        
        let javaScriptString = String(format: ScriptTemplates.AddEventListenerTemplate, javaScriptVariableName, callbackUUID!)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    public func removeEventListener() {
        if let uuid = callbackUUID {
            ClousureManager.removeEventCallback(forUUID: uuid)
            let javaScriptString = String(format: ScriptTemplates.RemoveEventListenerTemplate, javaScriptVariableName)
            map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    public func draw() {
        let javaScriptString = String(format: ScriptTemplates.PlaceTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    public func point(_ point: INCoordinates) {
        let pointString = CoordinatesHelper.coordinatesString(fromCoordinates: point)
        let javaScriptString = String(format: ScriptTemplates.PointTemplate, javaScriptVariableName, pointString)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    public func setLabel(withText text: String) {
        let javaScriptString = String(format: ScriptTemplates.SetLabelTemplate, javaScriptVariableName, text)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    public func removeLabel() {
        let javaScriptString = String(format: ScriptTemplates.RemoveLabelTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    public func setIcon(withPath path: String) {
        let javaScriptString = String(format: ScriptTemplates.SetIconTemplate, javaScriptVariableName, path)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
