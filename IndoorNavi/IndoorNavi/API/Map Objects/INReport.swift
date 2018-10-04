//
//  Report.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 07.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class containing methods to retrieve historical data.
public class INReport: NSObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "report%u"
        static let Initialization = "var %@ = new INReport('%@','%@');"
        static let Message = "{uuid: '%@', response: res}"
        static let GetAreaEvents = "%@.getAreaEvents(%d, new Date(%lu), new Date(%lu)).then(res => webkit.messageHandlers.AreaEventsCallbacksController.postMessage(%@));"
        static let GetCoordinates = "%@.getCoordinates(%d, new Date(%lu), new Date(%lu)).then(res => webkit.messageHandlers.CoordinatesCallbacksController.postMessage(%@));"
    }
    
    private var map: INMap
    private var javaScriptVariableName: String!
    private var targetHost: String
    private var apiKey: String
    
    /// Initializes a new `INReport` object with the provided parameters.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which object is going to be created.
    ///   - targetHost: Address to the `INMap` server.
    ///   - apiKey: The API key created on the `INMap` server.
    @objc public init(map: INMap, targetHost: String, apiKey: String) {
        self.map = map
        self.targetHost = targetHost
        self.apiKey = apiKey
        super.init()
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        initInJavaScript()
    }
    
    private func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName, targetHost, apiKey)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Returns array of historical `INArea` events.
    ///
    /// - Parameters:
    ///   - floorID: ID of the floor you want to get events from.
    ///   - from: Starting date of time period.
    ///   - to: Ending date of time period.
    ///   - completionHandler: A block to invoke when array of `AreaEvent` is available.
    public func getAreaEvents(fromFloorWithID floorID: Int, from: Date, to: Date, completionHandler: @escaping ([AreaEvent]) -> Void) {
        let uuid = UUID().uuidString
        map.areaEventsCallbacksController.areaEventCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetAreaEvents, javaScriptVariableName, floorID, from.timeIntervalSince1970.miliseconds, to.timeIntervalSince1970.miliseconds, message)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public func getAreaEvents(fromFloorWithID floorID: Int, from: Date, to: Date, callbackHandler: @escaping ([ObjCAreaEvent]) -> Void) {
        let callbackHandlerTakingStructs = AreaEventsHelper.callbackHandlerTakingStructs(fromCallbackHandlerTakingObjects: callbackHandler)
        getAreaEvents(fromFloorWithID: floorID, from: from, to: to, completionHandler: callbackHandlerTakingStructs)
    }
    
    /// Returns array of historical coordinates.
    ///
    /// - Parameters:
    ///   - floorID: ID of the floor you want to get coordinates from.
    ///   - from: Starting date of time period.
    ///   - to: Ending date of time period.
    ///   - completionHandler: A block to invoke when array of `Coordinates` is available.
    public func getCoordinates(fromFloorWithID floorID: Int, from: Date, to: Date, completionHandler: @escaping ([Coordinates]) -> Void) {
        let uuid = UUID().uuidString
        map.coordinatesCallbacksController.coordinatesCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetCoordinates, javaScriptVariableName, floorID, from.timeIntervalSince1970.miliseconds, to.timeIntervalSince1970.miliseconds, message)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public func getCoordinates(fromFloorWithID floorID: Int, from: Date, to: Date, callbackHandler: @escaping ([ObjCCoordinates]) -> Void) {
        let callbackHandlerTakingStructs = CoordinatesHelper.callbackHandlerTakingStructs(fromCallbackHandlerTakingObjects: callbackHandler)
        getCoordinates(fromFloorWithID: floorID, from: from, to: to, completionHandler: callbackHandlerTakingStructs)
    }
}
