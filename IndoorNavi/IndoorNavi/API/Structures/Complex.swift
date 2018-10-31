//
//  Complex.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing a complex.
public struct Complex: Equatable {
    
    /// `Complex`'s unique ifentifier.
    public var identifier: Int
    /// Name of the complex.
    public var name: String
    /// Array of all buildings in the `Complex`.
    public var buildings: [Building]
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Complex, rhs: Complex) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.name == rhs.name && lhs.buildings == rhs.buildings
    }
    
    /// Initializes a new `Complex` with the provided parameters.
    ///
    /// - Parameters:
    ///   - identifier: `Complex`'s unique ifentifier.
    ///   - name: Name of the complex.
    ///   - buildings: Array of all buildings in the `Complex`.
    init(identifier: Int, name: String, buildings: [Building]) {
        self.identifier = identifier
        self.name = name
        self.buildings = buildings
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let identifier = dictionary["id"] as? Int
            let name = dictionary["name"] as? String
            let buildings = ComplexHelper.buildings(fromJSONObject: dictionary["buildings"])
            
            if let identifier = identifier, let name = name{
                self.init(identifier: identifier, name: name, buildings: buildings)
                return
            }
        }
        
        assertionFailure("Could not initialize Complex from JSON object.")
        return nil
    }
}
