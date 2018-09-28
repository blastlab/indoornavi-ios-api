//
//  Building.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing building.
public struct Building {
    
    /// `Building`'s unique identifier.
    public var identifier: Int
    /// Name of the building.
    public var name: String
    /// Array of all floors in the `Building`.
    public var floors: [Floor]
    
    /// Initializes a new `Floor` with the provided parameters.
    ///
    /// - Parameters:
    ///   - identifier: `Building`'s unique identifier.
    ///   - name: Name of the building.
    ///   - floors: Array of all floors in the `Building`.
    public init(identifier: Int, name: String, floors: [Floor]) {
        self.identifier = identifier
        self.name = name
        self.floors = floors
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let identifier = dictionary["id"] as? Int
            let name = dictionary["name"] as? String
            let floors = ComplexHelper.floors(fromJSONObject: dictionary["level"])
            
            if let identifier = identifier, let name = name {
                self.init(identifier: identifier, name: name, floors: floors)
                return
            }
        }
        
        return nil
    }
}
