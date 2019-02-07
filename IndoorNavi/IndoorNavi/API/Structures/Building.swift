//
//  Building.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing building.
public struct Building: Equatable, Decodable {
    
    /// `Building`'s unique identifier.
    public var id: Int
    /// Name of the building.
    public var name: String
    /// Array of all floors in the `Building`.
    public var floors: [Floor]
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Building, rhs: Building) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.floors == rhs.floors
    }
    
    /// Initializes a new `Floor` with the provided parameters.
    ///
    /// - Parameters:
    ///   - id: `Building`'s unique identifier.
    ///   - name: Name of the building.
    ///   - floors: Array of all floors in the `Building`.
    init(id: Int, name: String, floors: [Floor]) {
        self.id = id
        self.name = name
        self.floors = floors
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let id = dictionary["id"] as? Int
            let name = dictionary["name"] as? String
            let floors = ComplexHelper.floors(fromJSONObject: dictionary["floors"])
            
            if let id = id, let name = name {
                self.init(id: id, name: name, floors: floors)
                return
            }
        }
        
        assertionFailure("Could not initialize Building from JSON object.")
        return nil
    }
}
