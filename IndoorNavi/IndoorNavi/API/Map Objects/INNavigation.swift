//
//  INNavigation.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 09/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// The delegate of a `INNavigation` object must adopt the `INNavigationDelegate` protocol. Methods of the protocol allow the delegate to monitor navigation activity.
public protocol INNavigationDelegate {
    
    /// Invoked when navigation has been created.
    ///
    /// - Parameter navigation: The navigation providing this information.
    func navigationCreated(_ navigation: INNavigation)
    
    /// Invoked when navigation has finished.
    ///
    /// - Parameter navigation: The navigation providing this information.
    func navigationFinished(_ navigation: INNavigation)
    
    /// Invoked when an error occured in navigation.
    ///
    /// - Parameter navigation: The navigation providing this information.
    func errorOccured(in navigation: INNavigation)
    
    /// Invoked when navigation is currently working and start was requested.
    ///
    /// - Parameter navigation: The navigation providing this information.
    func navigationIsWorking(_ navigation: INNavigation)
}

public extension INNavigationDelegate {
    func navigationIsWorking(_ navigation: INNavigation) {}
}

/// Class managing a BLE navigation. It calculates and draws a route from given postion to given destination. Updating ramaining route could be achieved by setting `bleLocationManager` with apprioprate object so that `INNavigation` knows how much of it left to reach destination.
public class INNavigation: NSObject {
    
    enum Event: String {
        case created = "created"
        case finished = "finished"
        case error = "error"
        case working = "working"
    }
    
    /// Struct representing graphic properties of navigation start and end points.
    public struct NavigationPointProperties {
        
        private static let ScriptTemplate = "new NavigationPoint(%d, %@, %f, '%@')"
        
        /// Radius of the point.
        public var radius: Int
        /// Point's `Border`.
        public var border: Border
        /// Color of the point.
        public var color: UIColor
        
        /// Initializes a new `NavigationPointProperties` with the provided parameters.
        ///
        /// - Parameters:
        ///   - radius: Radius of the point.
        ///   - border: Point's `Border`.
        ///   - color: Color of the point.
        public init(radius: Int = 10, border: Border? = nil, color: UIColor? = nil) {
            self.radius = radius
            self.border = border ?? Border(width: 2, color: .defaultNavigationColor)
            self.color = color ?? .defaultNavigationColor
        }
        
        var navigationPointScript: String {
            let navigationPointScript = String(format: NavigationPointProperties.ScriptTemplate, radius, border.borderScript, color.standarizedOpacity, color.colorString)
            return navigationPointScript
        }
    }
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "navigation%u"
        static let Initialization = "var %@ = new INNavigation(navi);"
        static let Start = "%@.start({x: %d, y: %d}, {x: %d, y: %d}, %d);"
        static let Message = "{uuid: '%@', response: res}"
        static let Stop = "%@.stop();"
        static let UpdatePosition = "%@.updatePosition({x: %d, y: %d});"
        static let AddEventListener = "%@.addEventListener(res => webkit.messageHandlers.NavigationCallbacksController.postMessage(%@));"
        static let RemoveEventListener = "%@.removeEventListener();"
        static let DisableStartPoint = "%@.disableStartPoint(%@);"
        static let DisableEndPoint = "%@.disableEndPoint(%@);"
        static let SetPathColor = "%@.setPathColor('%@');"
        static let SetStartPoint = "%@.setStartPoint(%@);"
        static let SetEndPoint = "%@.setEndPoint(%@);"
    }
    
    private let map: INMap
    private var javaScriptVariableName: String!
    
    private var lastPosition: INPoint?
    private var destination: INPoint?
    private var accuracy: Int?
    private var navigationCallbackUUID: UUID?
    
    /// `BLELocationManager` object, used to update remaining route. It should be set appropriately so that correct position can be obtained.
    public var bleLocationManager: BLELocationManager?
    
    /// The delegate object to receive navigation events.
    public var delegate: INNavigationDelegate? {
        didSet {
            delegate != nil ? addEventListener() : removeEventListener()
        }
    }
    
    /// A Boolean value indicating whether there is a navigation process.
    private(set) public var isNavigating = false
    
    /// A Boolean value indicating whether the start point is hidden.
    public var startPointHidden = false {
        didSet {
            let javaScriptString = String(format: ScriptTemplates.DisableStartPoint, javaScriptVariableName, startPointHidden ? "true" : "false")
            map.evaluate(javaScriptString)
        }
    }
    
    /// A Boolean value indicating whether the end point is hidden.
    public var endPointHidden = false {
        didSet {
            let javaScriptString = String(format: ScriptTemplates.DisableEndPoint, javaScriptVariableName, endPointHidden ? "true" : "false")
            map.evaluate(javaScriptString)
        }
    }
    
    /// Color of the navigation path.
    public var pathColor = UIColor.defaultNavigationColor {
        didSet {
            let javaScriptString = String(format: ScriptTemplates.SetPathColor, javaScriptVariableName, pathColor.colorString)
            map.evaluate(javaScriptString)
        }
    }
    
    /// Graphic properties of the navigation's start point.
    public var startPointProperties = NavigationPointProperties() {
        didSet {
            let javaScriptString = String(format: ScriptTemplates.SetStartPoint, javaScriptVariableName, startPointProperties.navigationPointScript)
            map.evaluate(javaScriptString)
        }
    }
    
    /// Graphic properties of the navigation's end point.
    public var endPointProperties = NavigationPointProperties() {
        didSet {
            let javaScriptString = String(format: ScriptTemplates.SetEndPoint, javaScriptVariableName, endPointProperties.navigationPointScript)
            map.evaluate(javaScriptString)
        }
    }
    
    /// Initializes a new `INNavigation` object with the provided parameters.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which object is going to be created.
    ///   - bleLocationManager: `BLELocationManager` object, used to update remaining route. Setting this value is optional. If set appriopriately, remaining route during navigation is being updated. If not set, `INNavigation` only draws a route. Default value is nil.
    public init(map: INMap, bleLocationManager: BLELocationManager? = nil, delegate: INNavigationDelegate? = nil) {
        self.map = map
        self.bleLocationManager = bleLocationManager
        self.delegate = delegate
        super.init()
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        initInJavaScript()
        if delegate != nil {
            addEventListener()
        }
    }
    
    private func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.Initialization, javaScriptVariableName)
        map.evaluate(javaScriptString)
    }
    
    /// Calculates shortest path for given beginning and destination coordinates.
    ///
    /// - Parameters:
    ///   - position: `INPoint` representing starting position from which navigation is going to begin. Should be given in real world dimensions, same as set for map's scale.
    ///   - destination: `INPoint` representing destination to which navigation is going to calculate and draw a path. Should be given in real world dimensions, same as set for map's scale.
    ///   - accuracy: Number representing margin for which navigation will pull point to the nearest path.
    public func startNavigation(from position: INPoint, to destination: INPoint, withAccuracy accuracy: Int) {
        
        guard let scale = map.scale else {
            assertionFailure("Scale has not loaded yet. Navigation could not be performed.")
            return
        }
        
        self.lastPosition = position
        self.destination = destination
        self.accuracy = accuracy
        
        if isNavigating {
            restartNavigation()
            return
        }
        
        let lastPositionInPixels = MapHelper.pixel(fromRealCoodinates: position, scale: scale)
        let destinationInPixels = MapHelper.pixel(fromRealCoodinates: destination, scale: scale)

        let javaScriptString = String(format: ScriptTemplates.Start, javaScriptVariableName, lastPositionInPixels.x, lastPositionInPixels.y, destinationInPixels.x, destinationInPixels.y, accuracy)
        map.evaluate(javaScriptString)
        self.isNavigating = true
        
        if let bleLocationManager = bleLocationManager {
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveData(_:)), name: .didUpdateLocation, object: bleLocationManager)
        }
    }
    
    /// Stop navigation process on demand.
    public func stopNavigation() {
        if isNavigating {
            let javaScriptString = String(format: ScriptTemplates.Stop, javaScriptVariableName)
            map.evaluate(javaScriptString)
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
    
    private func addEventListener() {
        navigationCallbackUUID = navigationCallbackUUID ?? UUID()
        map.navigationCallbacksController.navigationCallbacks[navigationCallbackUUID!.uuidString] = didReceive(_:)
        let message = String(format: ScriptTemplates.Message, navigationCallbackUUID!.uuidString)
        let javaScriptString = String(format: ScriptTemplates.AddEventListener, javaScriptVariableName, message)
        map.evaluate(javaScriptString)
    }
    
    private func didReceive(_ event: Event) {
        switch event {
        case .created:
            delegate?.navigationCreated(self)
        case .finished:
            delegate?.navigationFinished(self)
        case .error:
            delegate?.errorOccured(in: self)
        case .working:
            delegate?.navigationIsWorking(self)
        }
    }
    
    private func removeEventListener() {
        if let uuid = navigationCallbackUUID?.uuidString {
            map.navigationCallbacksController.navigationCallbacks.removeValue(forKey: uuid)
            navigationCallbackUUID = nil
            let javaScriptString = String(format: ScriptTemplates.RemoveEventListener, javaScriptVariableName)
            map.evaluate(javaScriptString)
        }
    }
    
    @objc private func didReceiveData(_ notification: Notification) {
        guard let location = notification.userInfo?["location"] as? INLocation else {
            assertionFailure("Could not read location data.")
            return
        }
        
        let position = INPoint(x: Int32(location.x.rounded()), y: Int32(location.y.rounded()))
        update(position: position)
    }
    
    private func update(position: INPoint) {
        
        guard let scale = map.scale else {
            return
        }
        
        lastPosition = position
        let lastPositionInPixels = MapHelper.pixel(fromRealCoodinates: position, scale: scale)
        let javaScriptString = String(format: ScriptTemplates.UpdatePosition, javaScriptVariableName, lastPositionInPixels.x, lastPositionInPixels.y)
        map.evaluate(javaScriptString)
    }
}
