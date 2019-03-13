//
//  NavigationCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 24/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import  WebKit

class NavigationCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "NavigationCallbacksController"
    
    var navigationCallbacks = [String: (INNavigation.Event) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let navigationCallback = navigationCallbacks[uuid], let dictionary = jsonObject as? [String: Any], let action = dictionary["status"] as? String, let event = INNavigation.Event(rawValue: action) {
            navigationCallback(event)
        }
    }
}

