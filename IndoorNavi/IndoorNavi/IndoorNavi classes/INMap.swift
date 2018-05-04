//
//  IndoorNavi.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 29.03.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import WebKit

/// Class representing an INMap
public class INMap: UIView, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    fileprivate struct ScriptTemplates {
        static let InitializationTemplate = "var navi = new INMap('%@','%@','map',{width:document.body.clientWidth,height:document.body.clientHeight});"
        static let LoadMapPromiseTemplate = "navi.load(%d).then(() => webkit.messageHandlers.iOS.postMessage('%@'));"
        static let LoadMapTemplate = "navi.load(%d);"
    }
    
    fileprivate struct WebViewConfigurationScripts {
        static let ViewportScriptString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        static let DisableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
        static let DisableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
    }
    
    fileprivate static let ControllerName = "iOS"
    
    private var webView: WKWebView!
    
    private var indoorNaviFrame: CGRect!
    private var targetHost: String!
    private var apiKey: String!
    
    private var initializedInJavaScript = false
    private var scriptsToEvaluateAfterInitialization = [String]()
    
    /**
     *  Loads map specified in function call.
     *
     *  - Parameters:
     *      - mapId: ID number of the map you want to load.
     *      - onCompletion: A block to invoke when the map is loaded.
     */
    public func load(_ mapId: Int, onCompletion: (() -> Void)? = nil) {
        var javaScriptString = String()
        
        if onCompletion != nil {
            let uuid = UUID().uuidString
            ClousureManager.promises[uuid] = onCompletion
            javaScriptString = String(format: ScriptTemplates.LoadMapPromiseTemplate, mapId, uuid)
        } else {
            javaScriptString = String(format: ScriptTemplates.LoadMapTemplate, mapId)
        }
        
        evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Initializes a new INMap object with the provided parameters to communicate with INMap frontend server.
     *
     *  - Parameters:
     *      - frame: Frame of the view containing map.
     *      - targetHost: Address to the INMap server.
     *      - apiKey: The API key created on INMap server.
     */
    public init(frame: CGRect, targetHost: String, apiKey: String) {
        super.init(frame: frame)
        
        self.indoorNaviFrame = frame
        self.targetHost = targetHost
        self.apiKey = apiKey
        
        setupWebView(withFrame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        loadHTML()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initInJavaScript() {
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, targetHost, apiKey)
        initializedInJavaScript = true
        evaluate(javaScriptString: javaScriptString)
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
        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true)
        webView.loadFileURL(Paths.indoorNaviHtmlURL, allowingReadAccessTo: baseURL)
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
        
        controller.add(self, name: INMap.ControllerName)
        configuration.userContentController = controller
        
        return configuration
    }
    
    private func evaluateSavedScripts() {
        for script in scriptsToEvaluateAfterInitialization {
            evaluate(javaScriptString: script)
        }
        scriptsToEvaluateAfterInitialization.removeAll()
    }
    
    // WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { // JS -> Swift
        print("Received event \(message.body)")
        if let uuid = message.body as? String {
            ClousureManager.receivedUUID(uuid)
        }
    }
    
    // WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initInJavaScript()
        evaluateSavedScripts()
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
