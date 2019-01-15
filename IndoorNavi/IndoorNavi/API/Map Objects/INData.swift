//
//  INData.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Object containing functions to retrieve data.
public class INData: NSObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "data%u"
        static let Initialization = "var %@ = new INData('%@','%@');"
        static let Message = "{uuid: '%@', response: res}"
        static let GetPaths = "%@.getPaths(%d).then(res => webkit.messageHandlers.GetPathsCallbacksController.postMessage(%@));"
        static let GetAreas = "%@.getAreas(%d).then(res => webkit.messageHandlers.GetAreasCallbacksController.postMessage(%@));"
        static let GetComplexes = "%@.getComplexes(res => webkit.messageHandlers.ComplexesCallbacksController.postMessage(%@));"
    }
    
    private let map: INMap
    private var javaScriptVariableName: String!
    private let targetHost: String
    private let apiKey: String
    
    /// Initializes a new `INData` object with the provided parameters.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which object is going to be created.
    ///   - targetHost: Address to the `INMap` backend server.
    ///   - apiKey: The API key created on the `INMap` server.
    public init(map: INMap, targetHost: String, apiKey: String) {
        self.map = map
        self.targetHost = targetHost
        self.apiKey = apiKey
        super.init()
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        initInJavaScript()
    }
    
    private func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName, targetHost, apiKey)
        map.evaluate(javaScriptString)
    }
    
    /// Returns array of `Path` representing paths on specified `floorID`.
    ///
    /// - Parameters:
    ///   - floorID: ID of the floor you want to get paths from.
    ///   - completionHandler: A block to invoke when array of `Path` is available.
    public func getPaths(fromFloorWithID floorID: Int, completionHandler: @escaping ([Path]) -> Void) {
        let uuid = UUID().uuidString
        map.getPathsCallbacksController.getPathsCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetPaths, javaScriptVariableName, floorID, message)
        map.evaluate(javaScriptString)
    }
    
    /// Returns array of `INArea` representing areas on specified `floorID`.
    ///
    /// - Parameters:
    ///   - floorID: ID of the floor you want to get paths from.
    ///   - completionHandler: A block to invoke when array of `INArea` is available.
    public func getAreas(fromFloorWithID floorID: Int, completionHandler: @escaping ([INArea]) -> Void) {
        let uuid = UUID().uuidString
        map.getAreasCallbacksController.getAreasCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetAreas, javaScriptVariableName, floorID, message)
        map.evaluate(javaScriptString)
    }
    
    /// Returns the list of complexes with all buildings and floors.
    ///
    /// - Parameter completionHandler: A block to invoke when array of `Complex` is available. This completion handler takes array of `Complex`'es.
    public func getComplexes(withCallbackHandler completionHandler: @escaping ([Complex]) -> Void) {
        let uuid = UUID().uuidString
        map.complexesCallbacksController.complexesCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetComplexes, javaScriptVariableName, message)
        map.evaluate(javaScriptString)
    }
}
