//
//  INObject.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

public class INObject: NSObject {
    
    var map: INMap!
    var javaScriptVariableName: String!
    
    public init(withMap map: INMap) {
        super.init()
        self.map = map
    }
    
    public func ready(readyClousure: @escaping () -> Void) {
        let uuid = UUID().uuidString
        ClousureManager.clousuresToPerform[uuid] = readyClousure
        let javaScriptString = String(format: "%@.ready().then(() =>  webkit.messageHandlers.iOS.postMessage('%@'));", javaScriptVariableName, uuid)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
}
