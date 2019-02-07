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
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] as? String, let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted) {
            receivedMessage(withUUID: uuid, andData: data)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andData data: Data) {
        if let complexesCallback = complexesCallbacks[uuid], let complexes = try? JSONDecoder().decode([Complex].self, from: data) {
            complexesCallback(complexes)
            complexesCallbacks.removeValue(forKey: uuid)
        }
    }
}
