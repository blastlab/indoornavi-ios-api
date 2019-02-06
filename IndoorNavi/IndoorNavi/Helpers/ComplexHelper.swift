//
//  ComplexHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28/09/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class ComplexHelper: NSObject {
    
    static func complexes(fromJSONObject jsonObject: Any?) -> [Complex] {
        if let complexesDictionaries = jsonObject as? [[String: Any]] {
            
            let complexes = complexesDictionaries.compactMap { element -> Complex? in
                let complex = Complex(fromJSONObject: element)
                return complex
            }
            
            return complexes
        } else {
            assertionFailure("Could not initialize array of Complex's from JSON object.")
            return [Complex]()
        }
    }
    
    static func buildings(fromJSONObject jsonObject: Any?) -> [Building] {
        if let dictionaries = jsonObject as? [[String: Any]] {
            
            let buildings = dictionaries.compactMap { element -> Building? in
                let floor = Building(fromJSONObject: element)
                return floor
            }
            
            return buildings
        } else {
            assertionFailure("Could not initialize array of Building's from JSON object.")
            return [Building]()
        }
    }
    
    static func floors(fromJSONObject jsonObject: Any?) -> [Floor] {
        if let dictionaries = jsonObject as? [[String: Any]] {
            
            let floors = dictionaries.compactMap { element -> Floor? in
                let floor = Floor(fromJSONObject: element)
                return floor
            }
            
            return floors
        } else {
            assertionFailure("Could not initialize array of Floor's from JSON object.")
            return [Floor]()
        }
    }
}
