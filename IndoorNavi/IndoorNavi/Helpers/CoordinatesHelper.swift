//
//  CoordinatesHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class CoordinatesHelper: NSObject {
    
    static func coordinatesArray(fromJSONObject jsonObject: Any?) -> [Coordinates] {
        if let dictionaries = jsonObject as? [[String: Any]] {
            
            let coordinatesArray = dictionaries.compactMap { element -> Coordinates? in
                let coordinates = Coordinates(fromJSONObject: element)
                return coordinates
            }
            
            return coordinatesArray
        } else {
            return [Coordinates]()
        }
    }
    
    static func callbackHandlerTakingStructs(fromCallbackHandlerTakingObjects callbackHandlerTakingObjects: @escaping ([ObjCCoordinates]) -> Void) -> ([Coordinates]) -> Void {
        let callbackHandlerTakingStructs: ([Coordinates]) -> Void = { coordinatesArray in
            let objCCoordinatesArray: [ObjCCoordinates] = coordinatesArray.map { coordinates in
                let objCCoordinates = ObjCCoordinates(x: coordinates.x, y: coordinates.y, tagID: coordinates.tagID, date: coordinates.date)
                return objCCoordinates
            }
            callbackHandlerTakingObjects(objCCoordinatesArray)
        }
        
        return callbackHandlerTakingStructs
    }
}
