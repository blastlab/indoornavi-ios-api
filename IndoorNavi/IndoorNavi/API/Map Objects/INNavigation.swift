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
    
    private var map: INMap
    private var javaScriptVariableName: String!
    
    private var lastPosition: INPoint?
    private var destination: INPoint?
    private var accuracy: Int?
    
    /// `BLELocationManager` object, used to update remaining route. It should be set appropriately so that correct position can be obtained.
    public var bleLocationManager: BLELocationManager?
    
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
    ///   - position: `INPoint` representing starting position from which navigation is going to begin.
    ///   - destination: `INPoint` representing destination to which navigation is going to calculate and draw a path.
    ///   - accuracy: Number representing margin for which navigation will pull point to the nearest path.
    public func startNavigation(from position: INPoint, to destination: INPoint, withAccuracy accuracy: Int) {
        self.lastPosition = position
        self.destination = destination
        self.accuracy = accuracy
        let javaScriptString = String(format: ScriptTemplates.Start, javaScriptVariableName, position.x, position.y, destination.x, destination.y, accuracy)
        map.evaluate(javaScriptString: javaScriptString)
        
        if let bleLocationManager = bleLocationManager {
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveData(_:)), name: .didUpdateLocation, object: bleLocationManager)
        }
    }
    
    /// Stop navigation process on demand.
    public func stopNavigation() {
        let javaScriptString = String(format: ScriptTemplates.Stop, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Restarts navigation process on demand.
    public func restartNavigation() {
        stopNavigation()
        if let lastPosition = lastPosition, let destination = destination, let accuracy = accuracy {
            startNavigation(from: lastPosition, to: destination, withAccuracy: accuracy)
        }
    }
    
    @objc private func didReceiveData(_ notification: Notification) {
        if let location = notification.userInfo?["location"] as? INLocation {
            let unitMultiplier = map.scale?.measure == .meters ? 1.0 : 100.0
            let position = INPoint(x: Int32((location.x * unitMultiplier).rounded()), y: Int32((location.y * unitMultiplier).rounded()))
            update(position: position)
        }
    }
    
    private func update(position: INPoint) {
        lastPosition = position
        let javaScriptString = String(format: ScriptTemplates.UpdatePosition, javaScriptVariableName, position.x, position.y)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
