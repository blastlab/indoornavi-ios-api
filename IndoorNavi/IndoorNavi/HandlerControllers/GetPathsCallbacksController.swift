//
//  GetPathsCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import  WebKit

class GetPathsCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "GetPathsCallbacksController"
    
    var getPathsCallbacks = [String: ([Path]) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let getPathsCallback = getPathsCallbacks[uuid] {
            let paths = DataHelper.paths(fromJSONObject: jsonObject)
            getPathsCallback(paths)
            getPathsCallbacks.removeValue(forKey: uuid)
        }
    }
}
