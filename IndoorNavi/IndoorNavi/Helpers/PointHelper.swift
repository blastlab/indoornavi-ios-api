//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class PointHelper {
    
    static func coordinatesArrayString(fromCoordinatesArray coordinatesArray: [Point]) -> String {
        let coordinatesStrings = coordinatesArray.map { "{x: \($0.x), y: \($0.y)}" }
        let coordinatesArrayString = "[" + coordinatesStrings.joined(separator: ",") + "]"
        
        return coordinatesArrayString
    }
    
    static func coordinatesString(fromCoordinates coordinates: Point) -> String {
        let coordinatesString = String(format: "{x: %d, y: %d}", coordinates.x, coordinates.y)
        return coordinatesString
    }
    
    static func coordinatesArray(fromJSONObject jsonObject: Any) -> [Point] {
        if let points = jsonObject as? [[String: Int]] {
            let coordinatesArray = points.compactMap { element -> Point? in
                
                if let x = element["x"], let y = element["y"] {
                    return Point(x: x, y: y)
                } else {
                    return nil
                }
            }
            return coordinatesArray
        } else {
            return [Point]()
        }
    }
}
