//
//  IndoorNavi.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 29.03.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import WebKit

public class IndoorNavi: UIView, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    
    private var indoorNaviFrame: CGRect!
    private var targetHost: String!
    private var apiKey: String!
    
    public func load(_ mapId: Int) {
        let javaScriptString = String(format: Constants.indoorNaviLoadMapTemplate, mapId)
        webView.evaluateJavaScript(javaScriptString, completionHandler: nil);
    }
    
    // Initialization
    public init(frame: CGRect, targetHost: String, apiKey: String) {
        super.init(frame: frame)
        
        self.indoorNaviFrame = frame
        self.targetHost = targetHost
        self.apiKey = apiKey
        
        setupWebView(withFrame: frame)
        
        loadHTML()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initInJavaScript() {
        let scale = UIScreen.main.scale
        print("Scale = %f",scale)
        
        let javaScriptString = String(format: Constants.indoorNaviInitializationTemplate, targetHost, apiKey, scale * indoorNaviFrame.width, scale * indoorNaviFrame.height)
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
        self.addSubview(webView)
    }
    
    private func loadHTML() {
        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true)
        
        webView.loadHTMLString(Constants.indoorNaviHtml, baseURL: baseURL)
    }
    
    private var configuration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
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
        print("Finished navigating to url \(String(describing: webView.url))")
        initInJavaScript()
    }
}
