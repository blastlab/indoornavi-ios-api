//
//  Border.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 29/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Struct representing border with specified `width` and `color`.
public struct Border {
    
    private static let ScriptTemplate = "new Border(%d, '%@')"
    
    /// Border's width in pixels.
    public var width: Int
    /// Color of the Border.
    public var color: UIColor
    
    /// Creates `Border` with the provided parameters.
    ///
    /// - Parameters:
    ///   - width: Border's width in pixels.
    ///   - color: Color of the Border.
    public init(width: Int, color: UIColor) {
        self.width = width
        self.color = color
    }
    
    var borderScript: String {
        let borderScript = String(format: Border.ScriptTemplate, width, color.colorString)
        return borderScript
    }
}
