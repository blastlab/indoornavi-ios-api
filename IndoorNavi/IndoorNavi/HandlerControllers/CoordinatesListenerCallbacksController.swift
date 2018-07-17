//
//  CoordinatesListenerCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 11.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class CoordinatesEventListenerCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "CoordinatesEventListenerCallbacksController"
    
    var coordinatesListenerCallbacks = [String: (Coordinates) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received area events callback with body: \(message.body)")
        
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let coordinatesListenerCallback = coordinatesListenerCallbacks[uuid] {
            if let areaEvent = Coordinates(fromJSONObject: jsonObject) {
                coordinatesListenerCallback(areaEvent)
            }
        }
    }
}
