//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 19.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class PointHelper {
    
    static func pointDictionary(fromPoint point: CGPoint) -> [String: CGFloat] {
        let pointDictionary = ["x": point.x, "y": point.y]
        return pointDictionary
    }
    
    static func pointsString(fromCoordinatesArray coordinatesArray: [INPoint]) -> String {
        let coordinatesStrings = coordinatesArray.map { "{x: \($0.x), y: \($0.y)}" }
        let coordinatesArrayString = "[" + coordinatesStrings.joined(separator: ",") + "]"
        
        return coordinatesArrayString
    }
    
    static func pointString(fromCoordinates coordinates: INPoint) -> String {
        let coordinatesString = String(format: "{x: %d, y: %d}", coordinates.x, coordinates.y)
        return coordinatesString
    }
    
    static func points(fromJSONObject jsonObject: Any?) -> [INPoint] {
        if let points = jsonObject as? [[String: Int]] {
            let coordinatesArray = points.compactMap { element -> INPoint? in
                let point = INPoint(fromJSONObject: element)
                return point
            }
            return coordinatesArray
        } else {
            assertionFailure("Could not initialize arrat of INPoint's from JSON object.")
            return [INPoint]()
        }
    }
    
    static func pointsArray(fromCArray pointer: UnsafePointer<INPoint>, withSize size:Int) -> [INPoint] {
        let points: [INPoint] = Array((UnsafeBufferPointer(start: pointer, count: size)))
        return points
    }
    
    static func pointsCArray(fromArray array:[INPoint]) -> (UnsafePointer<INPoint>,Int) {
        let pointer: UnsafePointer<INPoint> = UnsafePointer(array)
        return (pointer,array.count)
    }
    
    static func callbackHandlerTakingArray(fromCallbackHandlerTakingCArray callbackHandlerTakingCArray: @escaping (UnsafePointer<INPoint>?, Int) -> Void) -> ([INPoint]?) -> Void {
        let callbackHandlerTakingStructs: ([INPoint]?) -> Void = { points in
            if points != nil {
                let (pointer,count) = pointsCArray(fromArray: points!)
                callbackHandlerTakingCArray(pointer, count)
            } else {
                callbackHandlerTakingCArray(nil, 0)
            }
        }
        
        return callbackHandlerTakingStructs
    }
}
