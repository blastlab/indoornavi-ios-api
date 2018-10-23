//
//  INBle.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

public class INBle: NSObject {

    fileprivate struct ScriptTemplates {
        static let VariableName = "ble%u"
        static let Initialization = "var %@ = new INBle(%d, '%@', '%@');"
        static let UpdatePosition = "%@.updatePosition({x: %d, y: %d});"
        static let Message = "{uuid: '%@', response: res}"
        static let AddCallback = "%@.addCallbackFunction(res => webkit.messageHandlers.AreaEventListenerCallbacksController.postMessage(%@));"
    }
    
    public var bleLocationManager: BLELocationManager?
    
    private let map: INMap
    private var javaScriptVariableName: String!
    private let targetHost: String
    private let apiKey: String
    private let floorID: Int
    
    public init(map: INMap, targetHost: String, floorID: Int, apiKey: String, bleLocationManager: BLELocationManager? = nil) {
        self.map = map
        self.targetHost = targetHost
        self.apiKey = apiKey
        self.floorID = floorID
        super.init()
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        initInJavaScript()
    }
    
    private func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName, floorID, targetHost, apiKey)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    public func addAreaEventListener(withCallback areaEventCallback: @escaping (AreaEvent) -> Void) {
        let uuid = UUID().uuidString
        map.areaEventListenerCallbacksController.areaEventListenerCallbacks[uuid] = areaEventCallback
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.AddCallback, javaScriptVariableName, message)
        map.evaluate(javaScriptString: javaScriptString)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveData(_:)), name: .didUpdateLocation, object: bleLocationManager)
    }
    
    public func removeAreaEventListener() {
        
    }
    
    @objc private func didReceiveData(_ notification: Notification) {
        if let location = notification.userInfo?["location"] as? INLocation {
            let unitMultiplier = map.scale?.measure == .meters ? 1.0 : 100.0
            let position = INPoint(x: Int32((location.x * unitMultiplier).rounded()), y: Int32((location.y * unitMultiplier).rounded()))
            update(position: position)
        }
    }
    
    private func update(position: INPoint) {
        
        guard let scale = map.scale else {
            return
        }
        
        let pixelPosition = MapHelper.pixel(fromReaCoodinates: position, scale: scale)
        let javaScriptString = String(format: ScriptTemplates.UpdatePosition, javaScriptVariableName, pixelPosition.x, pixelPosition.y)
        map.evaluate(javaScriptString: javaScriptString)
    }
}

