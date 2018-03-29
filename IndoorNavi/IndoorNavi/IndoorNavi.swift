//
//  IndoorNavi.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 29.03.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import WebKit
import GCDWebServer

class IndoorNavi: UIView, WKUIDelegate, WKScriptMessageHandler, GCDWebServerDelegate {
    
    private var webView: WKWebView!
    private var serverURL : URL!
    private var server: GCDWebServer!
    
    // Initialization
    init(frame: CGRect, targetHost: String, apiKey: String, containerId: String) {
        super.init(frame: frame)
        webView = WKWebView.init(frame: frame, configuration: configuration)
        webView.uiDelegate = self
        self.addSubview(webView)
        setupServer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var configuration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
        controller.add(self, name: "iOS")
        configuration.userContentController = controller
        
        return configuration
    }
    
    private func setupServer() {
        server = GCDWebServer()
        server.delegate = self
        
        var html: String!
        
        do {
            try html = String(contentsOf: URL(fileURLWithPath: indexHtmlPath!), encoding: String.Encoding.utf8)
        } catch {
            print("Error")
            return
        }
        
        server.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: { request in
            
            return GCDWebServerDataResponse(html: html)
        })
        
        server.addGETHandler(forPath: "/indoornavi.js", filePath: indoorNaviPath!, isAttachment: true, cacheAge: 3600, allowRangeRequests: true)
        server.addGETHandler(forPath: "/dom.js", filePath: domPath!, isAttachment: true, cacheAge: 3600, allowRangeRequests: true)
        
        let options: [String : Any] = [GCDWebServerOption_RequestNATPortMapping : true, GCDWebServerOption_Port : 3000]
        
        do {
            try server.start(options: options)
        } catch {
            print("Error starting a server")
        }
    }
    
    // Paths
    private var indexHtmlPath: String? {
        if let path = Bundle.main.path(forResource: "index", ofType: "html") {
            print("Path: ",path)
            return path
        } else {
            print("Path error")
            return nil
        }
    }
    
    private var indoorNaviPath: String? {
        if let path = Bundle.main.path(forResource: "indoorNavi", ofType: "js") {
            print("Path: ",path)
            return path
        } else {
            print("Path error")
            return nil
        }
    }
    
    private var domPath: String? {
        if let path = Bundle.main.path(forResource: "dom", ofType: "js") {
            print("Path: ",path)
            return path
        } else {
            print("Path error")
            return nil
        }
    }
    
    // WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { // JS -> Swift
        print("Received event \(message.body)")
    }
    
    // WebServer delegate
    func webServerDidUpdateNATPortMapping(_ server: GCDWebServer) {
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
