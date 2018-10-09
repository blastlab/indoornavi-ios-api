//
//  GetAreasCallbacksController.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 05/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import  WebKit

class GetAreasCallbacksController: NSObject, WKScriptMessageHandler {
    
    static let ControllerName = "GetAreasCallbacksController"
    
    var getAreasCallbacks = [String: ([INArea]) -> Void]()
    weak var map: INMap?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dictionary = message.body as? [String: Any], let uuid = dictionary["uuid"] as? String, let response = dictionary["response"] {
            receivedMessage(withUUID: uuid, andJSONObject: response)
        }
    }
    
    private func receivedMessage(withUUID uuid: String, andJSONObject jsonObject: Any) {
        if let getAreasCallback = getAreasCallbacks[uuid], let map = map {
            let areas = DataHelper.areas(fromJSONObject: jsonObject, withMap: map)
            getAreasCallback(areas)
            getAreasCallbacks.removeValue(forKey: uuid)
        }
    }
}

