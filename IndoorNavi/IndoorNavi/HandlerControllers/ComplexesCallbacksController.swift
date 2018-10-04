//
//  ComplexesCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class ComplexesCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "ComplexesCallbacksController"
    
    var complexesCallbacks = [String: ([Complex]) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let complexesCallback = complexesCallbacks[uuid] {
            let complexes = ComplexHelper.complexes(fromJSONObject: jsonObject)
            complexesCallback(complexes)
            complexesCallbacks.removeValue(forKey: uuid)
        }
    }
}
