//
//  INBle.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class containing methods to handle BLE localization events.
public class INBle: NSObject {

    fileprivate struct ScriptTemplates {
        static let VariableName = "ble%u"
        static let Initialization = "var %@ = new INBle(%d, '%@', '%@');"
        static let UpdatePosition = "%@.updatePosition({x: %d, y: %d});"
        static let Message = "{uuid: '%@', response: res}"
        static let AddCallback = "%@.addCallbackFunction(res => webkit.messageHandlers.AreaEventListenerCallbacksController.postMessage(%@));"
    }
    
    private let bleLocationManager: BLELocationManager
    private let map: INMap
    private var javaScriptVariableName: String!
    private let targetHost: String
    private let apiKey: String
    private let floorID: Int
    private var areaEventListenerUUID: UUID?
    
    /// Initializes a new `INBle` object with the provided parameters.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which object is going to be created.
    ///   - targetHost: Address to the `INMap` backend server.
    ///   - floorID: ID number of the map you want to load.
    ///   - apiKey: The API key created on the `INMap` server.
    ///   - bleLocationManager: `BLELocationManager` object, used to update localization to check for area events. If set appriopriately, event listener is called on every event.
    public init(map: INMap, targetHost: String, floorID: Int, apiKey: String, bleLocationManager: BLELocationManager) {
        self.map = map
        self.targetHost = targetHost
        self.apiKey = apiKey
        self.floorID = floorID
        self.bleLocationManager = bleLocationManager
        super.init()
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        initInJavaScript()
    }
    
    private func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName, floorID, targetHost, apiKey)
        map.evaluate(javaScriptString)
    }
    
    /// Boolean value specifying whether it's the point pulled to path or the simple location data that should be monitored for possible area events. Default value is `false`.
    public var usePullToPath = false
    
    /// Adds a block to invoke when area event occurs.
    ///
    /// - Parameter areaEventCallback: A block to invoke when area event occurs.
    public func addAreaEventListener(withCallback areaEventCallback: @escaping (AreaEvent) -> Void) {
        areaEventListenerUUID = areaEventListenerUUID ?? UUID()
        map.areaEventListenerCallbacksController.areaEventListenerCallbacks[areaEventListenerUUID!.uuidString] = areaEventCallback
        let message = String(format: ScriptTemplates.Message, areaEventListenerUUID!.uuidString)
        let javaScriptString = String(format: ScriptTemplates.AddCallback, javaScriptVariableName, message)
        map.evaluate(javaScriptString)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveData(_:)), name: .didUpdateLocation, object: bleLocationManager)
    }
    
    /// Removes area event listener.
    public func removeAreaEventListener() {
        if let uuid = areaEventListenerUUID?.uuidString {
            map.areaEventListenerCallbacksController.areaEventListenerCallbacks.removeValue(forKey: uuid)
        }
        NotificationCenter.default.removeObserver(self)
        areaEventListenerUUID = nil
    }
    
    @objc private func didReceiveData(_ notification: Notification) {
        guard let location = notification.userInfo?["location"] as? INLocation else {
            assertionFailure("Could not read location data.")
            return
        }
        
        let unitMultiplier = map.scale?.measure == .meters ? 1.0 : 100.0
        let position = INPoint(x: Int32((location.x * unitMultiplier).rounded()), y: Int32((location.y * unitMultiplier).rounded()))
        update(position: position)
    }
    
    private func update(position: INPoint) {
        if usePullToPath {
            map.pullToPath(point: position, accuracy: 0) { pulledPosition in
                self.updatePositionInJavaScript(pulledPosition ?? position)
            }
        } else {
            updatePositionInJavaScript(position)
        }
    }
    
    private func updatePositionInJavaScript(_ position: INPoint) {
        guard let scale = map.scale else {
            assertionFailure("Scale has not loaded.")
            return
        }
        
        let pixelPosition = MapHelper.pixel(fromRealCoordinates: position, scale: scale)
        let javaScriptString = String(format: ScriptTemplates.UpdatePosition, javaScriptVariableName, pixelPosition.x, pixelPosition.y)
        map.evaluate(javaScriptString)
    }
}

