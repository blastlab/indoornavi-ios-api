//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

class CoordinatesHelper {
    
    static func coordinatesArrayString(fromCoordinatesArray coordinatesArray: [INCoordinates]) -> String {
        let coordinatesStrings = coordinatesArray.map { "{x: \($0.x), y: \($0.y)}" }
        let coordinatesArrayString = "[" + coordinatesStrings.joined(separator: ",") + "]"
        
        return coordinatesArrayString
    }
    
    static func coordinatesString(fromCoordinates coordinates: INCoordinates) -> String {
        let coordinatesString = String(format: "{x: %d, y: %d}", coordinates.x, coordinates.y)
        return coordinatesString
    }
    
    static func coordinatesArray(fromJSONObject jsonObject: Any) -> [INCoordinates] {
        if let points = jsonObject as? [[String: Int]] {
            let coordinatesArray = points.compactMap { element -> INCoordinates? in
                
                if let x = element["x"], let y = element["y"] {
                    return INCoordinates(x: x, y: y)
                } else {
                    return nil
                }
            }
            return coordinatesArray
        } else {
            return [INCoordinates]()
        }
    }
}
