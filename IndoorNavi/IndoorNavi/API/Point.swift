//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing a point on the map in centimiters as integers from real distances.
public struct Point {
    
    /// Horizontal coordinate in centimiters
    public var x: Int
    /// Vertical coordinate in centimiters
    public var y: Int
    
    /**
     *  Initializes a new `Point`.
     *
     *  - Parameters:
     *      - x: Horizontal coordinate in centimiters.
     *      - y: Vertical coordinate in centimiters
     */
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
