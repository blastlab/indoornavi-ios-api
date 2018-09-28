//
//  CoordinatesController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 08.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class CoordinatesCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "CoordinatesCallbacksController"
    
    var coordinatesCallbacks = [String: ([Coordinates]) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let coordinatesCallback = coordinatesCallbacks[uuid] {
            let coordinatesArray = CoordinatesHelper.coordinatesArray(fromJSONObject: jsonObject)
            coordinatesCallback(coordinatesArray)
            coordinatesCallbacks.removeValue(forKey: uuid)
        }
    }
}
