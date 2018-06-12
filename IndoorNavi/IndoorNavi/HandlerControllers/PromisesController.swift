//
//  PromiseController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 08.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import WebKit

class PromisesController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "PromisesController"
    
    var promises = [String: () -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received promise event with body: \(message.body)")
        if let uuid = message.body as? String {
            receivedMessage(withUUID: uuid)
        }
    }
    
    private func receivedMessage(withUUID uuid: String) {
        if let promiseResolveCallback = promises[uuid] {
            promiseResolveCallback()
            promises.removeValue(forKey: uuid)
        }
    }

}
