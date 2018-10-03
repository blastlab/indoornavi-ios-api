//
//  INPoint.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 25.06.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

extension INPoint : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: INPoint, rhs: INPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    /// The point with location (0,0).
    public static var zero: INPoint {
        return INPoint(x: 0, y: 0)
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let pointDictionary = jsonObject as? [String: Int32], let x = pointDictionary["x"], let y = pointDictionary["y"] {
            self.init(x: x, y: y)
        } else {
            return nil
        }
    }
}
