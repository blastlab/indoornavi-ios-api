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
public class IndoorNavi: UIView, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    
    private var indoorNaviFrame: CGRect!
    private var targetHost: String!
    private var apiKey: String!
    
    /**
     *  Loads map specified in function call.
     *
     *  - Parameter mapId: ID number of the map you want to load.
     */
    public func load(_ mapId: Int) {
        let javaScriptString = String(format: Constants.indoorNaviLoadMapTemplate, mapId)
        webView.evaluateJavaScript(javaScriptString, completionHandler: { response, error in
            print("Error: \(String(describing: error?.localizedDescription))")
            print("Response: \(String(describing: response))")
        })
    }
    
    // Initialization
    /**
     *   Initializes a new IndoorNavi object with the provided parameters to communicate with INMap frontend server.
     *
     *   - Parameters:
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
        let javaScriptString = String(format: Constants.indoorNaviInitializationTemplate, targetHost, apiKey)
        print("Java script string: \(javaScriptString)")
        
        webView.evaluateJavaScript(javaScriptString, completionHandler: { response, error in
            print("Error: \(String(describing: error?.localizedDescription))")
            print("Response: \(String(describing: response))")
        })
        
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
        
        let viewportScript = WKUserScript(source: Constants.viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let disableSelectionScript = WKUserScript(source: Constants.disableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let disableCalloutScript = WKUserScript(source: Constants.disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        controller.addUserScript(viewportScript)
        controller.addUserScript(disableSelectionScript)
        controller.addUserScript(disableCalloutScript)
        
        controller.add(self, name: "iOS")
        configuration.userContentController = controller
        
        return configuration
    }
    
    // WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { // JS -> Swift
        print("Received event \(message.body)")
    }
    
    // WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initInJavaScript()
    }
    
    // Deinitialization
    deinit {
        webView.scrollView.delegate = nil
    }
}
