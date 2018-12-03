//
//  IndoorNavi.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 29.03.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import WebKit

/// Class representing an `INMap`, communicates with frontend server.
public class INMap: UIView, WKUIDelegate, WKNavigationDelegate {
    
    fileprivate struct ScriptTemplates {
        static let Initialization = "var navi = new INMap('%@','%@','map',{width:document.body.clientWidth,height:document.body.clientHeight});"
        static let LoadMapPromise = "navi.load(%d).then(() => webkit.messageHandlers.PromisesController.postMessage('%@'));"
        static let LoadMap = "navi.load(%d);"
        static let Message = "{uuid: '%@', response: res}"
        static let AddLongClickListener = "navi.addMapLongClickListener(res => webkit.messageHandlers.LongClickEventCallbacksController.postMessage(%@));"
        static let Parameters = "navi.parameters;"
        static let ToggleTagVisibility = "navi.toggleTagVisibility(%d);"
        static let AddAreaEventListener = "navi.addEventListener(Event.LISTENER.AREA, res => webkit.messageHandlers.AreaEventListenerCallbacksController.postMessage(%@));"
        static let AddCoordinatesEventListener = "navi.addEventListener(Event.LISTENER.COORDINATES, res => webkit.messageHandlers.CoordinatesEventListenerCallbacksController.postMessage(%@));"
        static let GetComplexes = "navi.getComplexes(res => webkit.messageHandlers.ComplexesCallbacksController.postMessage(%@));"
        static let PullToPath = "navi.pullToPath({x: %d, y: %d}, %d, res => webkit.messageHandlers.PullToPathCallbacksController.postMessage(%@));"
    }
    
    fileprivate struct WebViewConfigurationScripts {
        static let ViewportScriptString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
    }
    
    /// Boolean value indicating if automatic floor change is enabled.
    ///
    /// To enable automatic floor change use instance method:
    /// ```
    /// enableFloorChange(wtihBLELocationManager: yourBLELocationManager)
    /// ```
    /// To disable automatic floor change use instance method:
    /// ```
    /// yourBLELocationManager.disableFloorChange()
    /// ```
    private(set) public var floorChangeEnabled = false
    /// `BLELocationManager` object, used to check foor floor changes if set. It should be set appropriately so that floor change could be performed.
    private(set) public var bleLocationManager: BLELocationManager?
    
    var promisesController = PromisesController()
    var eventCallbacksController = EventCallbacksController()
    var areaEventsCallbacksController = AreaEventsCallbacksController()
    var coordinatesCallbacksController = CoordinatesCallbacksController()
    var longClickEventCallbacksController = LongClickEventCallbacksController()
    var areaEventListenerCallbacksController = AreaEventListenerCallbacksController()
    var coordinatesEventListenerCallbacksController = CoordinatesEventListenerCallbacksController()
    var complexesCallbacksController = ComplexesCallbacksController()
    var pullToPathCallbacksController = PullToPathCallbacksController()
    var getPathsCallbacksController = GetPathsCallbacksController()
    var getAreasCallbacksController = GetAreasCallbacksController()
    var navigationCallbacksController = NavigationCallbacksController()
    
    private var webView: WKWebView!
    
    private var targetHost: String?
    private var apiKey: String?
    
    private var initializedInJavaScript = false
    private var scriptsToEvaluateAfterInitialization = [String]()
    private var scriptsToEvaluateAfterScaleLoad = [String]()
    
    private var areaEventListenerUUID: UUID?
    private var coordinatesEventListenerUUID: UUID?
    
    /// ID of the floor, which is currently displayed.
    private(set) public var floorID: Int?
    
    /// `Scale` object representing scale of the map
    private(set) public var scale: Scale? {
        didSet {
            if scale != nil {
                longClickEventCallbacksController.scale = scale
                pullToPathCallbacksController.scale = scale
                evaluateScriptsAfterScaleLoad()
            }
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc(scale) public var objCScale: ObjCScale? {
        if let scale = scale {
            return ObjCScale(fromScale: scale)
        } else {
            return nil
        }
    }
    
    /// Loads map specified in function call.
    ///
    /// - Parameters:
    ///   - floorID: ID number of the map you want to load.
    ///   - onCompletion: A block to invoke when the map is loaded.
    @objc public func load(_ floorID: Int, onCompletion: (() -> Void)? = nil) {
        self.floorID = floorID
        var javaScriptString = String()
        let uuid = UUID().uuidString
        
        promisesController.promises[uuid] = {
            self.getDimensions(onCompletion: onCompletion)
        }
        
        javaScriptString = String(format: ScriptTemplates.LoadMapPromise, floorID, uuid)
        evaluate(javaScriptString)
    }
    
    /// Enables automatic floor change on the `INMap` object. It also sets `bleLocationManager` property and `floorChangeEnabled` to `true`.
    ///
    /// - Parameter bleLocationManager: `BLELocationManager` object, used to check foor floor changes if set. It should be set appropriately so that floor change could be performed.
    public func enableFloorChange(wtihBLELocationManager bleLocationManager: BLELocationManager) {
        self.bleLocationManager = bleLocationManager
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveData(_:)), name: .didChangeFloor, object: bleLocationManager)
        floorChangeEnabled = true
    }
    
    /// Disables automatic floor change. It also sets `bleLocationManager` property to `nil` and `floorChangeEnabled` to `false`.
    public func disableFloorChange() {
        bleLocationManager = nil
        NotificationCenter.default.removeObserver(self)
        floorChangeEnabled = false
    }
    
    /// Initializes a new `INMap` object with the provided parameters to communicate with `INMap` frontend server.
    ///
    /// - Parameters:
    ///   - frame: Frame of the view containing map.
    ///   - targetHost: Address to the `INMap` backend server.
    ///   - apiKey: The API key created on the `INMap` server.
    @objc public init(frame: CGRect, targetHost: String, apiKey: String) {
        self.targetHost = targetHost
        self.apiKey = apiKey
        
        super.init(frame: frame)
        
        setupWebView(withFrame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        loadHTML()
    }
    
    /// Setups communication with `INMap` frontend server.
    ///
    /// - Parameters:
    ///   - targetHost: Address to the `INMap` backend server.
    ///   - apiKey: The API key created on the `INMap` server.
    @objc public func setupConnection(withTargetHost targetHost: String, andApiKey apiKey: String) {
        self.targetHost = targetHost
        self.apiKey = apiKey
        loadHTML()
    }
    
    /// Adds a block to invoke when the long click event occurs.
    ///
    /// - Parameter onLongClickCallback: A block to invoke when long click event occurs.
    @objc(addLongClickListener:) public func addLongClickListener(withCallback onLongClickCallback: @escaping (INPoint) -> Void) {
        let uuid = UUID().uuidString
        longClickEventCallbacksController.longClickEventCallbacks[uuid] = onLongClickCallback
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.AddLongClickListener, message)
        evaluateWhenScaleLoaded(javaScriptString)
    }
    
    /// Adds a block to invoke when area event occurs.
    ///
    /// - Parameter areaEventCallback: A block to invoke when area event occurs. This handler takes the point as a parameter given in real dimensions.
    public func addAreaEventListener(withCallback areaEventCallback: @escaping (AreaEvent) -> Void) {
        areaEventListenerUUID = areaEventListenerUUID ?? UUID()
        areaEventListenerCallbacksController.areaEventListenerCallbacks[areaEventListenerUUID!.uuidString] = areaEventCallback
        let message = String(format: ScriptTemplates.Message, areaEventListenerUUID!.uuidString)
        let javaScriptString = String(format: ScriptTemplates.AddAreaEventListener, message)
        evaluateWhenScaleLoaded(javaScriptString)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc(addAreaEventListener:) public func addAreaEventListener(withCallback callback: @escaping (ObjCAreaEvent) -> Void) {
        let callbackTakingStructs = AreaEventsHelper.callbackHandlerTakingStruct(fromCallbackHandlerTakingObject: callback)
        addAreaEventListener(withCallback: callbackTakingStructs)
    }
    
    /// Removes area event listener.
    public func removeAreaEventListener() {
        if let uuid = areaEventListenerUUID?.uuidString {
            areaEventListenerCallbacksController.areaEventListenerCallbacks.removeValue(forKey: uuid)
        }
        areaEventListenerUUID = nil
    }
    
    /// Adds a block to invoke when coordinates event occurs.
    ///
    /// - Parameter coordinatesListenerEventCallback: A block to invoke when coordinates event occurs.
    public func addCoordinatesEventListener(withCallback coordinatesListenerEventCallback: @escaping (Coordinates) -> Void) {
        coordinatesEventListenerUUID = coordinatesEventListenerUUID ?? UUID()
        coordinatesEventListenerCallbacksController.coordinatesListenerCallbacks[coordinatesEventListenerUUID!.uuidString] = coordinatesListenerEventCallback
        let message = String(format: ScriptTemplates.Message, coordinatesEventListenerUUID!.uuidString)
        let javaScriptString = String(format: ScriptTemplates.AddAreaEventListener, message)
        evaluateWhenScaleLoaded(javaScriptString)
    }
    
    /// Removes coordinates event listener.
    public func removeCoordinatesEventListener() {
        if let uuid = coordinatesEventListenerUUID?.uuidString {
            coordinatesEventListenerCallbacksController.coordinatesListenerCallbacks.removeValue(forKey: uuid)
        }
        coordinatesEventListenerUUID = nil
    }
    
    @available(swift, obsoleted: 1.0)
    @objc(addCoordinatesEventListener:) public func addCoordinatesEventListener(withCallback coordinatesListenerEventCallback: @escaping (ObjCCoordinates) -> Void) {
        let callbackTakingStructs = CoordinatesHelper.callbackHandlerTakingStruct(fromCallbackHandlerTakingObject: coordinatesListenerEventCallback)
        addCoordinatesEventListener(withCallback: callbackTakingStructs)
    }
    
    /// Toggles tag visibility specified by ID number.
    ///
    /// - Parameter ID: ID number of the specified tag.
    @objc public func toggleTagVisibility(withID ID: Int) {
        let javaScriptString = String(format: ScriptTemplates.ToggleTagVisibility, ID)
        evaluateWhenScaleLoaded(javaScriptString)
    }
    
    /// Returns the list of complexes with all buildings and floors.
    ///
    /// - Parameter completionHandler: A block to invoke when array of `Complex` is available. This completion handler takes array of `Complex`'es.
    public func getComplexes(withCallbackHandler completionHandler: @escaping ([Complex]) -> Void) {
        let uuid = UUID().uuidString
        complexesCallbacksController.complexesCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetComplexes, message)
        evaluateWhenScaleLoaded(javaScriptString)
    }
    
    /// Returns nearest position on path for given coordinates.
    ///
    /// - Parameters:
    ///   - point: The XY coordinates representing current coordinates in real world dimensions.
    ///   - accuracy: Accuracy of path pull. If set to 0, no accuracy is used and every position is pulled to path. This argument is optional. Default value is `0`.
    ///   - completionHandler: A block to invoke when calculated position on path is available. This completion handler takes an optional `INPoint` as a position on Path. Value is `nil` if position could not be calculated.
    public func pullToPath(point: INPoint, accuracy: Int = 0, withCompletionHandler completionHandler: @escaping (INPoint?) -> Void) {
        guard let scale = scale else {
            assertionFailure("Scale has not loaded yet. Could not pull to path.")
            return
        }
        let uuid = UUID().uuidString
        pullToPathCallbacksController.pullToPathCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let pixel = MapHelper.pixel(fromRealCoordinates: point, scale: scale)
        let normalizedAccuracy = accuracy >= 0 ? accuracy : 0
        let javaScriptString = String(format: ScriptTemplates.PullToPath, pixel.x, pixel.y, normalizedAccuracy, message)
        evaluateWhenScaleLoaded(javaScriptString)
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWebView(withFrame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        getAreasCallbacksController.map = self
    }
    
    private func initInJavaScript() {
        if let host = targetHost, let apiKey = apiKey {
            let javaScriptString = String(format: ScriptTemplates.Initialization, host, apiKey)
            initializedInJavaScript = true
            evaluate(javaScriptString)
        } else {
            assertionFailure("Could not initialize \(String(describing: self))")
        }
    }
    
    private func getDimensions(onCompletion: (() -> Void)? = nil) {
        evaluate(ScriptTemplates.Parameters) { response, error in
            guard let response = response, error == nil else {
                assert(error == nil || (error! as NSError).code == 5, "An error occured while obtaining map dimensions: \"\(error!.localizedDescription)\"")
                assertionFailure("Map dimensions could not be loaded.")
                return
            }
            
            if let scale = Scale(fromJSONObject: response) {
                self.scale = scale
                onCompletion?()
            }
        }
    }
    
    public override func layoutSubviews() {
        webView.frame = CGRect(x: 0, y: 0, width: super.bounds.width, height: super.bounds.height)
    }
    
    // Setups
    private func setupWebView(withFrame frame: CGRect) {
        webView = WKWebView.init(frame: frame, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.scrollView.bounces = false
        webView.scrollView.delegate = NativeWebViewScrollViewDelegate.shared
        
        self.addSubview(webView)
    }
    
    private func loadHTML() {
        webView.loadFileURL(Paths.indoorNaviHtmlURL, allowingReadAccessTo: Bundle(for: INMap.self).bundleURL)
    }
    
    private var configuration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
        let viewportScript = WKUserScript(source: WebViewConfigurationScripts.ViewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        controller.addUserScript(viewportScript)
        
        controller.add(promisesController, name: PromisesController.ControllerName)
        controller.add(eventCallbacksController, name: EventCallbacksController.ControllerName)
        controller.add(areaEventsCallbacksController, name: AreaEventsCallbacksController.ControllerName)
        controller.add(coordinatesCallbacksController, name: CoordinatesCallbacksController.ControllerName)
        controller.add(longClickEventCallbacksController, name: LongClickEventCallbacksController.ControllerName)
        controller.add(areaEventListenerCallbacksController, name: AreaEventListenerCallbacksController.ControllerName)
        controller.add(coordinatesEventListenerCallbacksController, name: CoordinatesEventListenerCallbacksController.ControllerName)
        controller.add(complexesCallbacksController, name: ComplexesCallbacksController.ControllerName)
        controller.add(pullToPathCallbacksController, name: PullToPathCallbacksController.ControllerName)
        controller.add(getPathsCallbacksController, name: GetPathsCallbacksController.ControllerName)
        controller.add(getAreasCallbacksController, name: GetAreasCallbacksController.ControllerName)
        controller.add(navigationCallbacksController, name: NavigationCallbacksController.ControllerName)
        configuration.userContentController = controller
        
        return configuration
    }
    
    private func evaluateScriptsAfterInitialization() {
        for script in scriptsToEvaluateAfterInitialization {
            evaluate(script)
        }
        scriptsToEvaluateAfterInitialization.removeAll()
    }
    
    private func evaluateScriptsAfterScaleLoad() {
        for script in scriptsToEvaluateAfterScaleLoad {
            evaluate(script)
        }
        scriptsToEvaluateAfterScaleLoad.removeAll()
    }
    
    @objc private func didReceiveData(_ notification: Notification) {
        guard let floorID = notification.userInfo?["floorID"] as? Int else {
            assertionFailure("Could not read floorID.")
            return
        }
        
        if self.floorID != floorID {
            load(floorID)
        }
    }
    
    // WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initInJavaScript()
        evaluateScriptsAfterInitialization()
    }
    
    func evaluate(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        if initializedInJavaScript {
            webView.evaluateJavaScript(javaScriptString) { response, error in
                completionHandler?(response, error)
            }
        } else {
            scriptsToEvaluateAfterInitialization.append(javaScriptString)
        }
    }
    
    private func evaluateWhenScaleLoaded(_ javaScriptString: String) {
        if scale != nil {
            evaluate(javaScriptString)
        } else {
            scriptsToEvaluateAfterScaleLoad.append(javaScriptString)
        }
    }
    
    // Deinitialization
    deinit {
        webView.scrollView.delegate = nil
    }
}
