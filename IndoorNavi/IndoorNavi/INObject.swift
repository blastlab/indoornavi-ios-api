//
//  INObject.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

public class INObject: NSObject {
    
    fileprivate struct ScriptTemplates {
        static let ReadyTemplate = "%@.ready().then(() => webkit.messageHandlers.iOS.postMessage('%@'));"
        static let GetIDTemplate = "%@.getID();"
        static let GetPointsTemplate = "%@.getPints();"
    }
    
    var map: INMap!
    var javaScriptVariableName: String!
    
    public init(withMap map: INMap) {
        super.init()
        self.map = map
    }
    
    public func ready(readyClousure: @escaping () -> Void) {
        let uuid = UUID().uuidString
        ClousureManager.clousuresToPerform[uuid] = readyClousure
        let javaScriptString = String(format: ScriptTemplates.ReadyTemplate, javaScriptVariableName, uuid)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    public func getID(callbackHandler: @escaping (Int?) -> Void) {
        let javaScriptString = String(format: ScriptTemplates.GetIDTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString) { response, error in
            
            guard error == nil else {
                print("Error: \(String(describing: error))")
                callbackHandler(nil)
                return
            }
            
            if let idNumber = response as? Int {
                callbackHandler(idNumber)
            } else {
                callbackHandler(nil)
            }
        }
    }
    
    public func getPoints(callbackHandler: @escaping (INCoordinates?) -> Void) {
        let javaScriptString = String(format: ScriptTemplates.GetIDTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString) { response, error in
            
            guard error == nil else {
                print("Error: \(String(describing: error))")
                callbackHandler(nil)
                return
            }
            
            if let coordinates = response as? INCoordinates {
                callbackHandler(coordinates)
            } else {
                callbackHandler(nil)
            }
        }
    }
}
