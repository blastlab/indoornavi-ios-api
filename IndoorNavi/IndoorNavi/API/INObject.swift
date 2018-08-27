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
    
    /// ID of the object. Remains `nil` until it is fully initialized.
    private(set) public var objectID: Int?
    
    @available(swift, obsoleted: 1.0)
    @objc(objectID) public var _ObjCobjectID: NSNumber? {
        return objectID as NSNumber?
    }
    
    /// Initializes a new `INObject` object inside given `INMap` object.
    ///
    /// - Parameter map: An `INMap` object, in which `INObject` is going to be created.
    @objc public init(withMap map: INMap) {
        self.map = map
        super.init()
        initInJavaScript()
        getID()
    }
    
    func initInJavaScript() {
        fatalError("Function must be implemented in subclass.")
    }
    
    private func getID() {
        let javaScriptString = String(format: ScriptTemplates.GetIDTemplate, javaScriptVariableName)
        ready {
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
    
    ///  Promise - that will resolve when connection to the frontend will be established, assures that instance of INMapObject has been created on the injected `INMap` class, this method should be executed before calling any other method on this object children.
    ///
    /// - Parameter readyClousure: A block to invoke when connection to the frontend is established and the object is ready.
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
    
    /// Returns the coordinates of the object.
    ///
    /// - Parameter callbackHandler: A block to invoke when the array of points is available.
    public func getPoints(callbackHandler: @escaping ([INPoint]?) -> Void) {
        let javaScriptString = String(format: ScriptTemplates.GetPointsTemplate, javaScriptVariableName)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString) { response, error in
                print("Response: \(String(describing: response))")
                print("Error: \(String(describing: error))")
                
                guard error == nil, response != nil else {
                    print("Error: \(String(describing: error))")
                    callbackHandler(nil)
                    return
                }
                
                let points = PointHelper.points(fromJSONObject: response!)
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
    
    /// Checks if point of given coordinates is inside the object. Use of this method is optional.
    ///
    /// - Parameters:
    ///   - coordinates: Coordinates that are described in real world dimensions. Coordinates are calculated to the map scale.
    ///   - callbackHandler: A block to invoke when the boolean is available.
    public func isWithin(coordinates: [INPoint], callbackHandler: @escaping (Bool?) -> Void) {
        let coordinatesString = PointHelper.pointsString(fromCoordinatesArray: coordinates)
        let javaScriptString = String(format: ScriptTemplates.IsWithinTemplate, javaScriptVariableName, coordinatesString)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString) { response, error in
                print("Response: \(String(describing: response))")
                print("Error: \(String(describing: error))")
                
                guard error == nil, response != nil else {
                    print("Error: \(String(describing: error))")
                    callbackHandler(nil)
                    return
                }
                
                if let isWithPoint = response! as? Bool {
                    callbackHandler(isWithPoint)
                } else {
                    callbackHandler(nil)
                }
            }
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public func isWithin(coordinates: UnsafePointer<INPoint>, withSize size: Int, callbackHandler: @escaping (Bool) -> Void)  {
        let coordinates = PointHelper.pointsArray(fromCArray: coordinates, withSize: size)
        
        let callback: (Bool?) -> Void = { isWithin in
            if let isWithin = isWithin {
                callbackHandler(isWithin)
            } else {
                callbackHandler(false)
            }
        }
        
        isWithin(coordinates: coordinates, callbackHandler: callback)
    }
    
    /// Removes object and destroys instance of the object in the frontend server, but do not destroys object class instance in your app.
    @objc public func remove() {
        let javaScriptString = String(format: ScriptTemplates.RemoveTemplate, javaScriptVariableName)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
}
