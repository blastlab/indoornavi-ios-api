//
//  EventsController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 08.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class EventCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "EventCallbacksController"
    
    var eventCallbacks = [String: () -> Void]()
    
    func removeEventCallback(forUUID uuid: String) {
        eventCallbacks.removeValue(forKey: uuid)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let uuid = message.body as? String {
            receivedMessage(withUUID: uuid)
        }
    }
    
    private func receivedMessage(withUUID uuid: String) {
        if let eventCallback = eventCallbacks[uuid] {
            eventCallback()
        }
    }
}
