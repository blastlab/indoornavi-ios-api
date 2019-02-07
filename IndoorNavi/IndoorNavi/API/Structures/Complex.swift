//
//  Complex.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing a complex.
public struct Complex: Equatable, Decodable {
    
    /// `Complex`'s unique ifentifier.
    public var id: Int
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
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.buildings == rhs.buildings
    }
    
    /// Initializes a new `Complex` with the provided parameters.
    ///
    /// - Parameters:
    ///   - id: `Complex`'s unique ifentifier.
    ///   - name: Name of the complex.
    ///   - buildings: Array of all buildings in the `Complex`.
    init(id: Int, name: String, buildings: [Building]) {
        self.id = id
        self.name = name
        self.buildings = buildings
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let id = dictionary["id"] as? Int
            let name = dictionary["name"] as? String
            let buildings = ComplexHelper.buildings(fromJSONObject: dictionary["buildings"])
            
            if let id = id, let name = name{
                self.init(id: id, name: name, buildings: buildings)
                return
            }
        }
        
        assertionFailure("Could not initialize Complex from JSON object.")
        return nil
    }
}
