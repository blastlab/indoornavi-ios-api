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
        static let SetInnerHTMLTemplate = "%@.setInnerHTML('%@');"
        static let SetPositionTemplate = "%@.setPosition(%i);"
    }
    
     /// Position regarding to related `INObject` object.
     ///
     /// - top: Top side position in regard to related object.
     /// - right: Right side position in regard to related object.
     /// - bottom: Bottom side position in regard to related object.
     /// - left: Left side position in regard to related object.
     /// - topRight: Top-right side position in regard to related object.
     /// - topLeft: Top-left side position in regard to related object.
     /// - bottomRight: Bottom-right side position in regard to related object.
     /// - bottomLeft: Bottom-left side position in regard to related object.
    @objc public enum Position: Int {
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
    
    /// Initializes a new `INInfoWindow` object inside given `INMap` object.
    ///
    /// - Parameters:
    ///   - map: An `INMap` object, in which `INArea` is going to be created.
    ///   - width: Width dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    ///   - height: Height dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    ///   - position: Position of info window regarding to object that info window will be appended to. Default position for info window is `.top`.
    ///   - innerHTML: Text or HTML template in string format that will be passed to info window as text.
    public convenience init(withMap map: INMap, width: Int? = nil, height: Int? = nil, position: Position? = nil, innerHTML: String? = nil) {
        self.init(withMap: map)
        if let width = width {
            self.width = width
        }
        if let height = height {
            self.height = height
        }
        if let position = position {
            self.position = position
        }
        if let innerHTML = innerHTML {
            setInnerHTML(string: innerHTML)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, width: Int, height: Int) {
        self.init(withMap: map, width: width, height: height)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, width: Int, height: Int, position: Position) {
        self.init(withMap: map, width: width, height: height, position: position)
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public convenience init(withMap map: INMap, width: Int, height: Int, position: Position, innerHTML: String) {
        self.init(withMap: map, width: width, height: height, position: position, innerHTML: innerHTML)
    }
    
    override func initInJavaScript() {
        javaScriptVariableName = String(format: ScriptTemplates.VariableName, hash)
        let javaScriptString = String(format: ScriptTemplates.InitializationTemplate, javaScriptVariableName)
        map.evaluate(javaScriptString: javaScriptString)
    }
    
    /// Height dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    @objc public var height: Int {
        get {
            return privateHeight
        }
        set {
            if newValue >= 50 {
                privateHeight = newValue
            } else {
                NSLog("INInfoWindow's height cannot be less than 50px. Height is set to 50px.")
                privateHeight = 50
            }
            
            let javaScriptString = String(format: ScriptTemplates.HeightTemplate, javaScriptVariableName, height)
            ready {
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /// Width dimension of info window. Setting this value is optional. Default value is 250px, minimum value is 50px.
    @objc public var width: Int {
        get {
            return privateWidth
        }
        set {
            if newValue >= 50 {
                privateHeight = newValue
            } else {
                NSLog("INInfoWindow's width cannot be less than 50px. Width is set to 50px.")
                privateHeight = 50
            }
            
            let javaScriptString = String(format: ScriptTemplates.WidthTemplate, javaScriptVariableName, privateWidth)
            ready {
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
    
    /// Sets info window content. To reset label to a new content call this method again passing new content as a string and call `draw()`.
    ///
    /// - Parameter string: Text or HTML template in string format that will be passed to info window as text.
    @objc public func setInnerHTML(string: String) {
        let javaScriptString = String(format: ScriptTemplates.SetInnerHTMLTemplate, javaScriptVariableName, string)
        ready {
            self.map.evaluate(javaScriptString: javaScriptString)
        }
    }
    
    /// Position of info window regarding to object that info window will be appended to. Default position for info window is `.top`.
    @objc public var position: Position = .top {
        didSet {
            let javaScriptString = String(format: ScriptTemplates.SetPositionTemplate, javaScriptVariableName, position.rawValue)
            ready {
                self.map.evaluate(javaScriptString: javaScriptString)
            }
        }
    }
}
