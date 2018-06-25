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
}
