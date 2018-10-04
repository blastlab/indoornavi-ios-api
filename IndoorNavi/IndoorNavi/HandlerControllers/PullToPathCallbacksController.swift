//
//  PullToPathCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 02/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class PullToPathCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "PullToPathCallbacksController"
    
    var pullToPathCallbacks = [String: (INPoint) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let pullToPathCallback = pullToPathCallbacks[uuid], let dictionary = jsonObject as? [String: Any], let locationDictionary = dictionary["calculatedPosition"], let position = INPoint(fromJSONObject: locationDictionary) {
            pullToPathCallback(position)
        }
        
        pullToPathCallbacks.removeValue(forKey: uuid)
    }
}
