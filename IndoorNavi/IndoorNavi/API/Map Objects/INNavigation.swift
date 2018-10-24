//
//  INNavigation.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 09/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class managing a BLE navigation. It calculates and draws a route from given postion to given destination. Updating ramaining route could be achieved by setting `bleLocationManager` with apprioprate object so that `INNavigation` knows how much of it left to reach destination.
public class INNavigation: NSObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "navigation%u"
        static let Initialization = "var %@ = new INNavigation(navi);"
        static let Start = "%@.start({x: %d, y: %d}, {x: %d, y: %d}, %d);"
        static let Stop = "%@.stop();"
        static let UpdatePosition = "%@.updatePosition({x: %d, y: %d});"
    }
    
    private let map: INMap
    private var javaScriptVariableName: String!
    
    private var lastPosition: INPoint?
    private var destination: INPoint?
    private var accuracy: Int?
    
    /// `BLELocationManager` object, used to update remaining route. It should be set appropriately so that correct position can be obtained.
    public var bleLocationManager: BLELocationManager?
    
    /// Boolean value indicating whether there is a navigation process.
    private(set) public var isNavigating = false
    
    /// Initializes a new `INNavigation` object with the provided parameters.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which object is going to be created.
    ///   - bleLocationManager: `BLELocationManager` object, used to update remaining route. Setting this value is optional. If set appriopriately, remaining route during navigation is being updated. If not set, `INNavigation` only draws a route. Default value is nil.
    public init(map: INMap, bleLocationManager: BLELocationManager? = nil) {
        self.map = map
        self.bleLocationManager = bleLocationManager
        super.init()
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        initInJavaScript()
    }
    
    private func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Calculates shortest path for given beginning and destination coordinates.
    ///
    /// - Parameters:
    ///   - position: `INPoint` representing starting position from which navigation is going to begin. Should be given in real world dimensions, same as set for map's scale.
    ///   - destination: `INPoint` representing destination to which navigation is going to calculate and draw a path. Should be given in real world dimensions, same as set for map's scale.
    ///   - accuracy: Number representing margin for which navigation will pull point to the nearest path.
    ///   - onCompletion: A block to invoke when the navigation has started.
    public func startNavigation(from position: INPoint, to destination: INPoint, withAccuracy accuracy: Int, onCompletion: (() -> Void)? = nil) {
        
        guard let scale = map.scale else {
            NSLog("Scale has not loaded yet. Navigation could not be performed.")
            return
        }
        
        self.lastPosition = position
        self.destination = destination
        self.accuracy = accuracy
        let javaScriptString = String(format: ScriptTemplates.Start, javaScriptVariableName, self.lastPosition!.x, self.lastPosition!.y, self.destination!.x, self.destination!.y, accuracy)
        
        if isNavigating {
            restartNavigation()
            return
        }
        let lastPositionInPixels = MapHelper.pixel(fromRealCoodinates: position, scale: scale)
        let destinationInPixels = MapHelper.pixel(fromRealCoodinates: destination, scale: scale)
        let javaScriptString = String(format: ScriptTemplates.Start, javaScriptVariableName, lastPositionInPixels.x, lastPositionInPixels.y, destinationInPixels.x, destinationInPixels.y, accuracy)
        map.evaluate(javaScriptString: javaScriptString)
        self.isNavigating = true
        
        if let bleLocationManager = bleLocationManager {
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveData(_:)), name: .didUpdateLocation, object: bleLocationManager)
        }
    }
    
    /// Stop navigation process on demand.
    public func stopNavigation() {
        if isNavigating {
            let javaScriptString = String(format: ScriptTemplates.Stop, javaScriptVariableName)
            map.evaluate(javaScriptString: javaScriptString)
            isNavigating = false
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    /// Restarts navigation process on demand.
    public func restartNavigation() {
        if isNavigating {
            stopNavigation()
        }
        if let lastPosition = lastPosition, let destination = destination, let accuracy = accuracy {
            startNavigation(from: lastPosition, to: destination, withAccuracy: accuracy)
        }
    }
    
    @objc private func didReceiveData(_ notification: Notification) {
        if let location = notification.userInfo?["location"] as? INLocation {
            let position = INPoint(x: Int32(location.x.rounded()), y: Int32(location.y.rounded()))
            update(position: position)
        }
    }
    
    private func update(position: INPoint) {
        
        guard let scale = map.scale else {
            return
        }
        
        lastPosition = position
        let lastPositionInPixels = MapHelper.pixel(fromRealCoodinates: position, scale: scale)
        let javaScriptString = String(format: ScriptTemplates.UpdatePosition, javaScriptVariableName, lastPositionInPixels.x, lastPositionInPixels.y)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
