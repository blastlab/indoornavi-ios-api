//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class PointHelper {
    
    static func coordinatesArrayString(fromCoordinatesArray coordinatesArray: [Point]) -> String {
        var coordinatesArrayString = "["
        
        for coordinates in coordinatesArray {
            coordinatesArrayString.append(self.coordinatesString(fromCoordinates: coordinates) + ",")
        }
        
        coordinatesArrayString.removeLast()
        coordinatesArrayString.append("]")
        
        return coordinatesArrayString
    }
    
    static func coordinatesString(fromCoordinates coordinates: Point) -> String {
        let coordinatesString = String(format: "{x: %d, y: %d}", coordinates.x, coordinates.y)
        return coordinatesString
    }
    
    static func coordinatesArray(fromJSONObject jsonObject: Any) -> [Point] {
        var coordinatesArray = [Point]()
        
        if let points = jsonObject as? [[String: Int]] {
            for point in points {
                if let x = point["x"], let y = point["y"] {
                    let coordinates = Point(x: x, y: y)
                    coordinatesArray.append(coordinates)
                }
            }
        }
        
        return coordinatesArray
    }
}
