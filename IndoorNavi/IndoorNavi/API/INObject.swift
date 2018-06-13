//
//  INObject.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class `INObject` is the root of the IndoorNavi objects hierarchy. Every IN object has `INObject` as a superclass (except `INMap`).
public class INObject: NSObject {
    
    fileprivate struct ScriptTemplates {
        static let ReadyTemplate = "%@.ready().then(() => webkit.messageHandlers.PromisesController.postMessage('%@'));"
        static let GetIDTemplate = "%@.getID();"
        static let GetPointsTemplate = "%@.getPoints();"
        static let IsWithinTemplate = "%@.isWithin(%@);"
        static let RemoveTemplate = "%@.remove();"
    }
    
    private(set) var javaScriptVariableName: String!
    let map: INMap
    
    /**
     *  ID of the object. Remains `nil` until it is fully initialized.
     *
     *  - Parameter callbackHandler: A block to invoke when the ID is available.
     */
    private(set) public var objectID: Int?
    
    /**
     *  Initializes a new `INObject` object inside given `INMap` object.
     *
     *  - Parameter withMap: An `INMap` object, in which `INObject` is going to be created.
     */
    public init(withMap map: INMap, variableNameTemplate: String) {
        self.map = map
        super.init()
        javaScriptVariableName = String(format: variableNameTemplate, hash)
        ready {
            self.getID { objectID in
                self.objectID = objectID
            }
        }
    }
    
    private func getID(callbackHandler: @escaping (Int?) -> Void) {
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
    
    /**
     *  Promise - that will resolve when connection to the frontend will be established, assures that instance of INMapObject has been created on the injected `INMap` class, this method should be executed before calling any other method on this object children.
     *
     *  - Parameter onCompletion: A block to invoke when connection to the frontend is established and the object is ready.
     */
    func ready(readyClousure: @escaping () -> Void) {
        if objectID != nil {
            readyClousure()
        } else {
            let uuid = UUID().uuidString
            map.promisesController.promises[uuid] = readyClousure
            let javaScriptString = String(format: ScriptTemplates.ReadyTemplate, javaScriptVariableName, uuid)
            map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Returns the coordinates of the object.
     *
     *  - Parameter callbackHandler: A block to invoke when the array of points is available.
     */
    public func getPoints(callbackHandler: @escaping ([Point]?) -> Void) {
        let javaScriptString = String(format: ScriptTemplates.GetPointsTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString) { response, error in
            print("Response: \(String(describing: response))")
            print("Error: \(String(describing: error))")
            
            guard error == nil, response != nil else {
                print("Error: \(String(describing: error))")
                callbackHandler(nil)
                return
            }
            
            let points = PointHelper.coordinatesArray(fromJSONObject: response!)
            print("Points: ",points)
            callbackHandler(points)
        }
    }
    
    /**
     *  Checks if point of given coordinates is inside the object. Use of this method is optional.
     *
     *  - Parameters:
     *      - coordinates: Coordinates that are described in real world dimensions. Coordinates are calculated to the map scale.
     *      - callbackHandler: A block to invoke when the boolean is available.
     */
    public func isWithin(coordinates: [Point], callbackHandler: @escaping (Bool) -> Void) {
        let coordinatesString = PointHelper.coordinatesArrayString(fromCoordinatesArray: coordinates)
        let javaScriptString = String(format: ScriptTemplates.IsWithinTemplate, javaScriptVariableName, coordinatesString)
        map.evaluate(javaScriptString: javaScriptString) { response, error in
            print("Response: \(String(describing: response))")
            print("Error: \(String(describing: error))")
            
            guard error == nil, response != nil else {
                print("Error: \(String(describing: error))")
                callbackHandler(false)
                return
            }
            
            if let isWithPoint = response! as? Bool {
                callbackHandler(isWithPoint)
            } else {
                callbackHandler(false)
            }
        }
    }
    
    /**
     *  Removes object and destroys instance of the object in the frontend server, but do not destroys object class instance in your app.
     */
    public func remove() {
        let javaScriptString = String(format: ScriptTemplates.RemoveTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
