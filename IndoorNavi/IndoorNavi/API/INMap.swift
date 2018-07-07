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
        static let InitializationTemplate = "var navi = new INMap('%@','%@','map',{width:document.body.clientWidth,height:document.body.clientHeight});"
        static let LoadMapPromiseTemplate = "navi.load(%d).then(() => webkit.messageHandlers.PromisesController.postMessage('%@'));"
        static let LoadMapTemplate = "navi.load(%d);"
        static let MessageTemplate = "{uuid: '%@', response: res}"
        static let AddLongClickListener = "navi.addMapLongClickListener(res => webkit.messageHandlers.LongClickEventCallbacksController.postMessage(%@));"
        static let Parameters = "navi.parameters;"
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
    
    private var webView: WKWebView!
    
    private var targetHost: String?
    private var apiKey: String?
    
    private var initializedInJavaScript = false
    private var scriptsToEvaluateAfterInitialization = [String]()
    private var scriptsToEvaluateAfterScaleLoad = [String]()
    
    public var scale: Scale? {
        didSet {
            if scale != nil {
                evaluateScriptsAfterScaleLoad()
            }
        }
    }
    
    /// Loads map specified in function call.
    ///
    /// - Parameters:
    ///   - mapId: ID number of the map you want to load.
    ///   - onCompletion: A block to invoke when the map is loaded.
    @objc public func load(_ mapId: Int, onCompletion: (() -> Void)? = nil) {
        var javaScriptString = String()
        let callback = {
            self.getDimensions()
            onCompletion?()
        }
        
        let uuid = UUID().uuidString
        promisesController.promises[uuid] = callback
        javaScriptString = String(format: ScriptTemplates.LoadMapPromiseTemplate, mapId, uuid)
        
        evaluate(javaScriptString: javaScriptString)
    }
    
    /// Initializes a new `INMap` object with the provided parameters to communicate with `INMap` frontend server.
    ///
    /// - Parameters:
    ///   - frame: Frame of the view containing map.
    ///   - targetHost: Address to the INMap server.
    ///   - apiKey: The API key created on the INMap server.
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
    ///   - targetHost: Address to the INMap server.
    ///   - apiKey: The API key created on the INMap server.
    @objc public func setupConnection(withTargetHost targetHost: String, andApiKey apiKey: String) {
        self.targetHost = targetHost
        self.apiKey = apiKey
        loadHTML()
    }
    
    @objc public func addLongClickListener(onLongClickCallback: @escaping (INPoint) -> Void) {
        let uuid = UUID().uuidString
        longClickEventCallbacksController.longClickEventCallbacks[uuid] = onLongClickCallback
        let message = String(format: ScriptTemplates.MessageTemplate, uuid)
        let javaScriptString = String(format: ScriptTemplates.AddLongClickListener, message)
        evaluate(javaScriptString: javaScriptString)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWebView(withFrame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
    }
    
    private func initInJavaScript() {
        if let host = targetHost, let apiKey = apiKey {
            let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, host, apiKey)
            initializedInJavaScript = true
            evaluate(javaScriptString: javaScriptString)
        }
    }
    
    private func getDimensions() {
        evaluate(javaScriptString: ScriptTemplates.Parameters) { response, error in
            
            guard error == nil, response != nil else {
                print("Error: \(String(describing: error))")
                return
            }
            
            if let scale = Scale(fromJSONObject: response!) {
                self.scale = scale
            }
        }
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
    
    internal func evaluate(javaScriptString string: String) {
        evaluate(javaScriptString: string) { response, error in
            print("Error: \(String(describing: error?.localizedDescription))")
            print("Response: \(String(describing: response))")
        }
    }
    
    internal func evaluate(javaScriptString string: String, completionHandler: @escaping (Any?, Error?) -> Void) {
        if initializedInJavaScript {
            print("Evaluating script: \(string)")
            webView.evaluateJavaScript(string, completionHandler: completionHandler)
        } else {
            scriptsToEvaluateAfterInitialization.append(string)
        }
    }
    
    // Deinitialization
    deinit {
        webView.scrollView.delegate = nil
    }
}
