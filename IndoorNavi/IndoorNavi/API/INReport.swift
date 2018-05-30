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
        static let InitializationTemplate = "var %@ = new INReport('%@','%@');"
        static let MessageTemplate = "{uuid: '%@', response: res}"
        static let GetAreaEventsTemplate = "%@.getAreaEvents(%d, new Date(%lu), new Date(%lu)).then(res => webkit.messageHandlers.AreaEventsCallbacksController.postMessage(%@));"
        static let GetCoordinatesTemplate = "%@.getCoordinates(%d, new Date(%lu), new Date(%lu)).then(res => webkit.messageHandlers.CoordinatesCallbacksController.postMessage(%@));"
    }
    
    private var map: INMap!
    private var javaScriptVariableName: String!
    private var targetHost: String!
    private var apiKey: String!
    
    /**
     *  Initializes a new `INReport` object with the provided parameters.
     *
     *  - Parameters:
     *      - map: An INMap object, in which Report is going to be created.
     *      - targetHost: Address to the INMap server.
     *      - apiKey: The API key created on the INMap server.
     */
    public init(map: INMap, targetHost: String, apiKey: String) {
        super.init()
        self.map = map
        self.targetHost = targetHost
        self.apiKey = apiKey
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, self.hash)
        
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName, targetHost, apiKey)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Returns list of historical `INArea` events.
     *
     *  - Parameters:
     *      - fromFloorWithID: ID of the floor you want to get events from.
     *      - from: Starting date of time period.
     *      - to: Ending date of time period.
     *      - callbackHandler: A block to invoke when array of `AreaEvent` is available.
     */
    public func getAreaEvents(fromFloorWithID floorID: Int, from: Date, to: Date, callbackHandler: @escaping ([AreaEvent]) -> Void) {
        let uuid = UUID().uuidString
        map.areaEventsCallbacksController.areaEventCallbacks[uuid] = callbackHandler
        let message = String(format: ScriptTemplates.MessageTemplate, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetAreaEventsTemplate, javaScriptVariableName, floorID, from.timeIntervalSince1970.miliseconds, to.timeIntervalSince1970.miliseconds, message)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Returns list of historical coordinates.
     *
     *  - Parameters:
     *      - fromFloorWithID: ID of the floor you want to get coordinates from.
     *      - from: Starting date of time period.
     *      - to: Ending date of time period.
     *      - callbackHandler: A block to invoke when array of `Coordinates` is available.
     */
    public func getCoordinates(fromFloorWithID floorID: Int, from: Date, to: Date, callbackHandler: @escaping ([Coordinates]) -> Void) {
        let uuid = UUID().uuidString
        map.coordinatesCallbacksController.coordinatesCallbacks[uuid] = callbackHandler
        let message = String(format: ScriptTemplates.MessageTemplate, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetCoordinatesTemplate, javaScriptVariableName, floorID, from.timeIntervalSince1970.miliseconds, to.timeIntervalSince1970.miliseconds, message)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
