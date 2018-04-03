//
//  IndoorNavi.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 29.03.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import WebKit

public class IndoorNavi: UIView, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, GCDWebServerDelegate {
    
    private var webView: WKWebView!
    private var serverURL : URL!
    private var server: GCDWebServer!
    
    private let html = "<html><head></head><body><div id=\"map\"></div></body><script src=\"indoorNavi.js\"></script></html>"
    private let indoorNaviTemplate = "var navi = new IndoorNavi(\"%@\",\"%@\",\"%@\",{width:%f,height:%f});"
    
    private var indoorNaviFrame: CGRect!
    private var targetHost: String!
    private var apiKey: String!
    private var containerId: String!
    
    public func load(_ mapId: Int) {
        let javaScriptString = String(format: "navi.load(%i);", mapId)
        
        webView.evaluateJavaScript(javaScriptString, completionHandler: nil);
    }
    
    public func testFunc() {
        webView.evaluateJavaScript("var a = 5;", completionHandler: { result, error in
            print("Test error: \(String(describing: error?.localizedDescription))")
        });
        webView.evaluateJavaScript("a;", completionHandler: { result, error in
            print("Test error: \(String(describing: error?.localizedDescription))")
        });
    }
    
    // Initialization
    public init(frame: CGRect, targetHost: String, apiKey: String, containerId: String) {
        super.init(frame: frame)
        
        self.indoorNaviFrame = frame
        self.targetHost = targetHost
        self.apiKey = apiKey
        self.containerId = containerId
        
        setupWebView(withFrame: frame)
        setupServer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var configuration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
        controller.add(self, name: "iOS")
        configuration.userContentController = controller
        
        return configuration
    }
    
    private func exportToJavaScript() {
        let scale = UIScreen.main.scale
        print("Scale = %f",scale)
        let javaScriptString = String(format: indoorNaviTemplate, targetHost, apiKey, containerId, scale * indoorNaviFrame.width, scale * indoorNaviFrame.height)
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
    
    private func setupServer() {
        server = GCDWebServer()
        server.delegate = self
        
        server.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: { request in
            
            return GCDWebServerDataResponse(html: self.html)
        })
        
        server.addGETHandler(forPath: "/indoornavi.js", filePath: indoorNaviPath!, isAttachment: true, cacheAge: 3600, allowRangeRequests: true)
//        server.addGETHandler(forPath: "/dom.js", filePath: domPath!, isAttachment: true, cacheAge: 3600, allowRangeRequests: true)
        
        let options: [String : Any] = [GCDWebServerOption_RequestNATPortMapping : true, GCDWebServerOption_Port : 3000]
        
        do {
            try server.start(options: options)
        } catch {
            print("Error starting a server")
        }
    }
    
    // Paths
    private var indoorNaviPath: String? {
        let bundle = Bundle(for: IndoorNavi.self)
        if let path = bundle.path(forResource: "indoorNavi", ofType: "js") {
            print("Path: ",path)
            return path
        } else {
            print("Path error")
            return nil
        }
    }
    
    private var domPath: String? {
        let bundle = Bundle(for: IndoorNavi.self)
        if let path = bundle.path(forResource: "dom", ofType: "js") {
            print("Path: ",path)
            return path
        } else {
            print("Path error")
            return nil
        }
    }
    
    // WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { // JS -> Swift
        print("Received event \(message.body)")
    }
    
    // WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished navigating to url \(String(describing: webView.url))")
        exportToJavaScript()
    }
    
    // WebServer delegate
    public func webServerDidUpdateNATPortMapping(_ server: GCDWebServer) {
        print("Web server did update NAT port mapping")
        print("publicServerURL: \(String(describing: server.publicServerURL ))")
        print("serverURL: \(String(describing: server.serverURL))")
        
        if let url = server.serverURL {
            print("URL: \(url)")
            serverURL = url
            webView.load( URLRequest(url: url) )
        }
    }
}
