//
//  INInfoWindow.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 02.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class representing an info window, creates an `INInfoWindow` object in iframe that communicates with frontend server and adds info window to a given `INObject` child.
public class INInfoWindow: INObject {
    
    fileprivate struct ScriptTemplates {
        static let VariableName = "infoWindow%u"
        static let InitializationTemplate = "var %@ = new INInfoWindow(navi);"
        static let HeightTemplate = "%@.height(%i);"
        static let WidthTemplate = "%@.width(%i);"
        static let OpenTemplate = "%@.open(%@);"
        static let SetInnerHTMLTemplate = "%@.setInnerHTML('%@');"
        static let SetPositionTemplate = "%@.setPosition(%i);"
    }
    
    /**
     *  Position regarding to related `INObject` object.
     *
     *  - top: Top side position in regard to related object.
     *  - right: Right side position in regard to related object.
     *  - bottom: Bottom side position in regard to related object.
     *  - left: Left side position in regard to related object.
     *  - topRight: Top-right side position in regard to related object.
     *  - topLeft: Top-left side position in regard to related object.
     *  - bottomRight: Bottom-right side position in regard to related object.
     *  - bottomLeft: Bottom-left side position in regard to related object.
     */
    public enum Position: Int {
        case top
        case right
        case bottom
        case left
        case topRight
        case topLeft
        case bottomRight
        case bottomLeft
    }
    
    private var privateWidth = 250
    private var privateHeight = 250
    
    /**
     *  Initializes a new `INInfoWindow` object inside given `INMap` object.
     *
     *  - Parameter withMap: An `INMap` object, in which `INArea` is going to be created.
     */
    public init(withMap map: INMap) {
        super.init(withMap: map, variableNameTemplate: ScriptTemplates.VariableName)
        
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        self.map.evaluate(javaScriptString: javaScriptString)
    }
    
    /**
     *  Height dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
     */
    public var height: Int {
        get {
            return privateHeight
        }
        set {
            guard newValue >= 50 else {
                NSLog("INInfoWindow's height cannot be less than 50px. Height is set to 50px.")
                print("Private height = \(privateHeight)")
                return
            }
            
            privateHeight = newValue
            ready {
                let javaScriptString = String(format: ScriptTemplates.HeightTemplate, self.javaScriptVariableName, self.height)
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /**
     *  Width dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
     */
    public var width: Int {
        get {
            return privateWidth
        }
        set {
            guard newValue >= 50 else {
                NSLog("INInfoWindow's width cannot be less than 50px. Width is set to 50px.")
                print("Private width = \(privateWidth)")
                return
            }
            
            privateWidth = newValue
            ready {
                let javaScriptString = String(format: ScriptTemplates.WidthTemplate, self.javaScriptVariableName, self.privateWidth)
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /**
     *  Displays info window in iframe on given object.
     *
     *  - Parameter object: An INObject object to append info window to.
     */
    public func open(object: INObject) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.OpenTemplate, self.javaScriptVariableName, object.javaScriptVariableName)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Sets info window content. To reset label to a new content call this method again passing new content as a string and call `draw()`.
     *
     *  - Parameter string: Text or HTML template in string format that will be passed to info window as text.
     */
    public func setInnerHTML(string: String) {
        ready {
            let javaScriptString = String(format: ScriptTemplates.SetInnerHTMLTemplate, self.javaScriptVariableName, string)
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /**
     *  Position of info window regarding to object that info window will be appended to. Default position for info window is `.top`.
     */
    public var position: Position = .top {
        didSet {
            ready {
                let javaScriptString = String(format: ScriptTemplates.SetPositionTemplate, self.javaScriptVariableName, self.position.rawValue)
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
}
