//
//  Complex.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing a complex.
public struct Complex {
    
    /// `Complex`'s unique ifentifier.
    public var identifier: Int
    /// Name of the complex.
    public var name: String
    /// Array of all buildings in the `Complex`.
    public var buildings: [Building]
    
    /// Initializes a new `Complex` with the provided parameters.
    ///
    /// - Parameters:
    ///   - identifier: `Complex`'s unique ifentifier.
    ///   - name: Name of the complex.
    ///   - buildings: Array of all buildings in the `Complex`.
    public init(identifier: Int, name: String, buildings: [Building]) {
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
        
        return nil
    }
}
