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
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let areaEventListenerCallback = areaEventListenerCallbacks[uuid], let areaEvent = AreaEvent(fromJSONObject: jsonObject) ?? AreaEvent(fromBleJSONObject: jsonObject) {
            areaEventListenerCallback(areaEvent)
        }
    }
}
