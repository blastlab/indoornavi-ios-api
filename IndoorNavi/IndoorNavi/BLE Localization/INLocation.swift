//
//  INLocation.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 14.09.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// The XY coordinates representing current location.
public struct INLocation {
    /// The x-coordinate.
    public var x: Double
    /// The y-coordinate.
    public var y: Double
    
    public static func == (lhs: INLocation, rhs: INLocation) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    /// The point with location (0,0).
    public static var zero: INLocation {
        return INLocation(x: 0, y: 0)
    }
}
