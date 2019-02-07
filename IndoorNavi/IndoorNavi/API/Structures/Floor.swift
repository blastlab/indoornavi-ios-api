//
//  Floor.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing a floor.
public struct Floor: Equatable, Decodable {
    
    /// `Flour`'s unique identifier.
    public var id: Int
    /// Name of the floor.
    public var name: String
    /// `Floor`'s level.
    public var level: Int
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Floor, rhs: Floor) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.level == rhs.level
    }
    
    /// Initializes a new `Floor` with the provided parameters.
    ///
    /// - Parameters:
    ///   - id: `Flour`'s unique identifier.
    ///   - name: Name of the floor.
    ///   - level: `Floor`'s level.
    init(id: Int, name: String, level: Int) {
        self.id = id
        self.name = name
        self.level = level
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let id = dictionary["id"] as? Int
            let name = dictionary["name"] as? String
            let level = dictionary["level"] as? Int
            
            if let id = id, let name = name, let level = level {
                self.init(id: id, name: name, level: level)
                return
            }
        }
        
        assertionFailure("Could not initialize Floor from JSON object.")
        return nil
    }
}
