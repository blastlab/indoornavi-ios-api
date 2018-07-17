//
//  AreaEventListenerCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 11.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class AreaEventListenerCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "AreaEventListenerCallbacksController"
    
    var areaEventListenerCallbacks = [String: (AreaEvent) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received area events callback with body: \(message.body)")
        
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let areaEventListenerCallback = areaEventListenerCallbacks[uuid] {
            if let areaEvent = AreaEvent(fromJSONObject: jsonObject) {
                areaEventListenerCallback(areaEvent)
            }
        }
    }
}
