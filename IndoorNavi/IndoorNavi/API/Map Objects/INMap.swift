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
        static let PullToPath = "navi.pullToPath({x: %d, y: %d}, %d).then(res => webkit.messageHandlers.PullToPathCallbacksController.postMessage(%@));"
    }
    
    fileprivate struct WebViewConfigurationScripts {
        static let ViewportScriptString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        static let DisableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
        static let DisableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
    }
    
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
    ///   - mapId: ID number of the map you want to load.
    ///   - onCompletion: A block to invoke when the map is loaded.
    @objc public func load(_ mapId: Int, onCompletion: (() -> Void)? = nil) {
        var javaScriptString = String()
        let uuid = UUID().uuidString
        
        promisesController.promises[uuid] = {
            self.getDimensions(onCompletion: onCompletion)
        }
        
        javaScriptString = String(format: ScriptTemplates.LoadMapPromise, mapId, uuid)
        evaluate(javaScriptString: javaScriptString)
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
        evaluateWhenScaleLoaded(javaScriptString: javaScriptString)
    }
    
    /// Adds a block to invoke when area event occurs.
    ///
    /// - Parameter areaEventCallback: A block to invoke when area event occurs. This handler takes the point as a parameter given in real dimensions.
    public func addAreaEventListener(withCallback areaEventCallback: @escaping (AreaEvent) -> Void) {
        areaEventListenerUUID = UUID()
        let uuid = areaEventListenerUUID!.uuidString
        areaEventListenerCallbacksController.areaEventListenerCallbacks[uuid] = areaEventCallback
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.AddAreaEventListener, message)
        evaluateWhenScaleLoaded(javaScriptString: javaScriptString)
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
        coordinatesEventListenerUUID = UUID()
        let uuid = coordinatesEventListenerUUID!.uuidString
        coordinatesEventListenerCallbacksController.coordinatesListenerCallbacks[uuid] = coordinatesListenerEventCallback
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.AddAreaEventListener, message)
        evaluateWhenScaleLoaded(javaScriptString: javaScriptString)
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
        evaluateWhenScaleLoaded(javaScriptString: javaScriptString)
    }
    
    /// Returns the list of complexes with all buildings and floors.
    ///
    /// - Parameter completionHandler: A block to invoke when array of `Complex` is available. This completion handler takes array of `Complex`'es.
    public func getComplexes(withCallbackHandler completionHandler: @escaping ([Complex]) -> Void) {
        let uuid = UUID().uuidString
        complexesCallbacksController.complexesCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let javaScriptString = String(format: ScriptTemplates.GetComplexes, message)
        evaluateWhenScaleLoaded(javaScriptString: javaScriptString)
    }
    
    /// Returns nearest position on path for given coordinates.
    ///
    /// - Parameters:
    ///   - point: The XY coordinates representing current coordinates in real world dimensions.
    ///   - accuracy: Accuracy of path pull.
    ///   - completionHandler: A block to invoke when calculated position on path is available. This completion handler takes `INPoint` as a position on Path.
    public func pullToPath(point: INPoint, accuracy: Int, withCompletionHandler completionHandler: @escaping (INPoint) -> Void) {
        guard let scale = scale else {
            NSLog("Scale has not loaded yet. Could not pull to path.")
            return
        }
        let uuid = UUID().uuidString
        pullToPathCallbacksController.pullToPathCallbacks[uuid] = completionHandler
        let message = String(format: ScriptTemplates.Message, uuid)
        let pixel = MapHelper.pixel(fromRealCoodinates: point, scale: scale)
        let javaScriptString = String(format: ScriptTemplates.PullToPath, pixel.x, pixel.y, accuracy, message)
        evaluateWhenScaleLoaded(javaScriptString: javaScriptString)
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
            evaluate(javaScriptString: javaScriptString)
        }
    }
    
    private func getDimensions(onCompletion: (() -> Void)? = nil) {
        evaluate(javaScriptString: ScriptTemplates.Parameters) { response, error in
            
            guard error == nil, response != nil else {
                NSLog("Error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            if let scale = Scale(fromJSONObject: response!) {
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
        let disableSelectionScript = WKUserScript(source: WebViewConfigurationScripts.DisableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let disableCalloutScript = WKUserScript(source: WebViewConfigurationScripts.DisableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        controller.addUserScript(viewportScript)
        controller.addUserScript(disableSelectionScript)
        controller.addUserScript(disableCalloutScript)
        
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
            evaluate(javaScriptString: script)
        }
        scriptsToEvaluateAfterInitialization.removeAll()
    }
    
    private func evaluateScriptsAfterScaleLoad() {
        for script in scriptsToEvaluateAfterScaleLoad {
            evaluate(javaScriptString: script)
        }
        scriptsToEvaluateAfterScaleLoad.removeAll()
    }
    
    // WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initInJavaScript()
        evaluateScriptsAfterInitialization()
    }
    
    func evaluate(javaScriptString string: String, completionHandler: ((Any?, Error?) -> Void)? = nil ) {
        if initializedInJavaScript {
//            print("string: \(string)")
            webView.evaluateJavaScript(string, completionHandler: completionHandler)
        } else {
            scriptsToEvaluateAfterInitialization.append(string)
        }
    }
    
    private func evaluateWhenScaleLoaded(javaScriptString string: String) {
        if scale != nil {
            evaluate(javaScriptString: string)
        } else {
            scriptsToEvaluateAfterScaleLoad.append(string)
        }
    }
    
    // Deinitialization
    deinit {
        webView.scrollView.delegate = nil
    }
}
