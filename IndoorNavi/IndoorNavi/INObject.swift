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
        static let GetPointsTemplate = "%@.getPoints();"
        static let IsWithinTemplate = "%@.isWithin(%@);"
        static let RemoveTemplate = "%@.remove();"
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
            
            guard error == nil, response != nil else {
                print("Error: \(String(describing: error))")
                callbackHandler(nil)
                return
            }
            
            if let idNumber = response! as? Int {
                callbackHandler(idNumber)
            } else {
                callbackHandler(nil)
            }
        }
    }
    
    public func getPoints(callbackHandler: @escaping ([INCoordinates]?) -> Void) {
        let javaScriptString = String(format: ScriptTemplates.GetPointsTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString) { response, error in
            print("Response: \(String(describing: response))")
            print("Error: \(String(describing: error))")
            
            guard error == nil, response != nil else {
                print("Error: \(String(describing: error))")
                callbackHandler(nil)
                return
            }
            
            let points = CoordinatesHelper.coordinatesArray(fromJSONObject: response!)
            print("Points: ",points)
            callbackHandler(points)
        }
    }
    
    public func isWithin(coordinates: [INCoordinates], callbackHandler: @escaping (Bool) -> Void) {
        let coordinatesString = CoordinatesHelper.coordinatesArrayString(fromCoordinatesArray: coordinates)
        let javaScriptString = String(format: ScriptTemplates.IsWithinTemplate, javaScriptVariableName, coordinatesString)
        map.evaluate(javaScriptString: javaScriptString) { response, error in
            print("Response: \(String(describing: response))")
            print("Error: \(String(describing: error))")
            
            guard error == nil, response != nil else {
                print("Error: \(String(describing: error))")
                callbackHandler(false)
                return
            }
            
            if let isWithinCoordinates = response! as? Bool {
                callbackHandler(isWithinCoordinates)
            } else {
                callbackHandler(false)
            }
        }
    }
    
    public func remove() {
        let javaScriptString = String(format: ScriptTemplates.RemoveTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
