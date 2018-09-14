//
//  INLocation.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 14.09.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

public struct INLocation {
    public var x: Double
    public var y: Double
    
    public static func == (lhs: INLocation, rhs: INLocation) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public static var zero: INLocation {
        return INLocation(x: 0, y: 0)
    }
}
