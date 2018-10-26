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
        static let ReadyNative = "%@.ready().then(() => webkit.messageHandlers.PromisesController.postMessage('%@'));"
        static let Ready = "%@.ready().then(() => {%@});"
        static let GetID = "%@.getID();"
        static let Remove = "%@.remove();"
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
        let javaScriptString = String(format: ScriptTemplates.GetID, self.javaScriptVariableName)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString) { response, error in
                
                guard error == nil, response != nil else {
                    NSLog("Error: \(String(describing: error))")
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
            let javaScriptString = String(format: ScriptTemplates.ReadyNative, javaScriptVariableName, uuid)
            map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    func ready(_ readyScript: String) {
        if objectID != nil {
            map.evaluate(javaScriptString: readyScript)
        } else {
            let javaScriptString = String(format: ScriptTemplates.Ready, javaScriptVariableName, readyScript)
            map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Removes object and destroys instance of the object in the frontend server, but do not destroys object class instance in your app.
    @objc public func remove() {
        let javaScriptString = String(format: ScriptTemplates.Remove, self.javaScriptVariableName)
        ready(javaScriptString)
    }
}
