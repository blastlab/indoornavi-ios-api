//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

/// Structure representing point's coordinates on map in centimiters as integers from real distances.
public struct INCoordinates {
    
    public var x: Int
    public var y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
