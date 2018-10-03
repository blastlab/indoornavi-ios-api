//
//  LongClickEventCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 06.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class LongClickEventCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "LongClickEventCallbacksController"
    
    var longClickEventCallbacks = [String: (INPoint) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let longClickEventCallback = longClickEventCallbacks[uuid], let dictionary = jsonObject as? [String: Any], let point = INPoint(fromJSONObject: dictionary["position"]) {
            longClickEventCallback(point)
        }
    }
}
