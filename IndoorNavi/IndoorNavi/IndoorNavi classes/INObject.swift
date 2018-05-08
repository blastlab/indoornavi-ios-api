//
//  INObject.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class INObject is the root of the IndoorNavi objects hierarchy. Every IN object has INObject as a superclass (except INMap).
public class INObject: NSObject {
    
    fileprivate struct ScriptTemplates {
        static let ReadyTemplate = "%@.ready().then(() => webkit.messageHandlers.PromisesController.postMessage('%@'));"
        static let GetIDTemplate = "%@.getID();"
        static let GetPointsTemplate = "%@.getPoints();"
        static let IsWithinTemplate = "%@.isWithin(%@);"
        static let RemoveTemplate = "%@.remove();"
    }
    
    var map: INMap!
    var javaScriptVariableName: String!
    
    /**
     *  Initializes a new INObject object inside given INMap object.
     *
     *  - Parameter withMap: An INMap object, in which INObject is going to be created.
     */
    public init(withMap map: INMap) {
        super.init()
        self.map = map
    }
    
    /**
     *  Promise - that will resolve when connection to the frontend will be established, assures that instance of INMapObject has been created on the injected INMap class, this method should be executed before calling any other method on this object children.
     *
     *  - Parameter onCompletion: A block to invoke when connection to the frontend is established and the object is ready.
     */
    public func ready(readyClousure: @escaping () -> Void) {
        let uuid = UUID().uuidString
        map.promisesController.promises[uuid] = readyClousure
        let javaScriptString = String(format: ScriptTemplates.ReadyTemplate, javaScriptVariableName, uuid)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Returns the ID of the object.
     *
     *  - Parameter callbackHandler: A block to invoke when the ID is available.
     */
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
    
    /**
     *  Returns the coordinates of the object.
     *
     *  - Parameter callbackHandler: A block to invoke when the array of points is available.
     */
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
    
    /**
     *  Checks if point of given coordinates is inside the object. Use of this method is optional.
     *
     *  - Parameters:
     *      - coordinates: Coordinates that are described in real world dimensions. Coordinates are calculated to the map scale.
     *      - callbackHandler: A block to invoke when the boolean is available.
     */
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
    
    /**
     *  Removes object and destroys instance of the object in the frontend server, but do not destroys object class instance in your app.
     */
    public func remove() {
        let javaScriptString = String(format: ScriptTemplates.RemoveTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
}
