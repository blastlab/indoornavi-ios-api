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
    
    var javaScriptVariableName: String!
    let map: INMap
    
    /**
     *  ID of the object. Remains `nil` until it is fully initialized.
     *
     *  - Parameter callbackHandler: A block to invoke when the ID is available.
     */
    private(set) public var objectID: Int?
    
    @available(swift, obsoleted: 1.0)
    @objc(objectID) public var _ObjCobjectID: NSNumber? {
        return objectID as NSNumber?
    }
    
    /**
     *  Initializes a new `INObject` object inside given `INMap` object.
     *
     *  - Parameter withMap: An `INMap` object, in which `INObject` is going to be created.
     */
    init(withMap map: INMap) {
        self.map = map
        super.init()
        initInJavaScript()
        getID()
    }
    
    func initInJavaScript() {
        fatalError("Function must be implemented in subclass.")
    }
    
    private func getID() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.GetIDTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString) { response, error in
                
                guard error == nil, response != nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                
                if let idNumber = response! as? Int {
                    self.objectID = idNumber
                }
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
    public func getPoints(callbackHandler: @escaping ([INPoint]?) -> Void) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.GetPointsTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString) { response, error in
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
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public func getPoints(callbackHandler: @escaping (_ pointsArray: UnsafePointer<INPoint>?,_ size:Int) -> Void) {
        let callbackHandlerTakingArrayOfStructs = PointHelper.callbackHandlerTakingArray(fromCallbackHandlerTakingCArray: callbackHandler)
        getPoints(callbackHandler: callbackHandlerTakingArrayOfStructs)
    }
    
    /**
     *  Checks if point of given coordinates is inside the object. Use of this method is optional.
     *
     *  - Parameters:
     *      - coordinates: Coordinates that are described in real world dimensions. Coordinates are calculated to the map scale.
     *      - callbackHandler: A block to invoke when the boolean is available.
     */
    public func isWithin(coordinates: [INPoint], callbackHandler: @escaping (Bool) -> Void) {
        ready {
            let coordinatesString = PointHelper.coordinatesArrayString(fromCoordinatesArray: coordinates)
            let javaScriptString = String(format: ScriptTemplates.IsWithinTemplate, self.javaScriptVariableName, coordinatesString)
            self.map.evaluate(javaScriptString: javaScriptString) { response, error in
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
    }
    
    @available(swift, obsoleted: 1.0)
    @objc private func isWithin(coordinates: UnsafePointer<INPoint>, withSize size: Int, callbackHandler: @escaping (Bool) -> Void)  {
        let coordinates = PointHelper.pointsArray(fromCArray: coordinates, withSize: size)
        isWithin(coordinates: coordinates, callbackHandler: callbackHandler)
    }
    
    /**
     *  Removes object and destroys instance of the object in the frontend server, but do not destroys object class instance in your app.
     */
    @objc public func remove() {
        ready {
            let javaScriptString = String(format: ScriptTemplates.RemoveTemplate, self.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
