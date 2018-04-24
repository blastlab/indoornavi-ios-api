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
        var coordinatesArrayString = "["
        
        for coordinates in coordinatesArray {
            coordinatesArrayString.append(self.coordinatesString(fromCoordinates: coordinates) + ",")
        }
        
        coordinatesArrayString.removeLast()
        coordinatesArrayString.append("]")
        
        return coordinatesArrayString
    }
    
    static func coordinatesString(fromCoordinates coordinates: INCoordinates) -> String {
        let coordinatesString = String(format: "{x: %d, y: %d}", coordinates.x, coordinates.y)
        return coordinatesString
    }
}
