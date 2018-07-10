//
//  ValueCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 08.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class AreaEventsCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "AreaEventsCallbacksController"
    
    var areaEventCallbacks = [String: ([AreaEvent]) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received area events callback with body: \(message.body)")
        
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let areaEventCallback = areaEventCallbacks[uuid] {
            let areaEvents = AreaEventsHelper.areaEvents(fromJSONObject: jsonObject)
            areaEventCallback(areaEvents)
            areaEventCallbacks.removeValue(forKey: uuid)
        }
    }
}
