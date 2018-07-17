//
//  MapHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Class containing functions enabling parsing data from pixels to real dimensions unit
public class MapHelper: NSObject {
    
    /// Converts pixel point to the point corresponding to the actual location in proper unit.
    ///
    /// - Parameters:
    ///   - pixel: `INPoint` describing location of the pixel.
    ///   - scale: `Scale` of the map.
    /// - Returns: `INPoint` describing location of the point given in real dimensions, specified in `scale`.
    public static func realCoordinates(fromPixel pixel: INPoint, scale: Scale) -> INPoint {
        let x = Int32(Double(pixel.x) * scale.centimetresPerPixel)
        let y = Int32(Double(pixel.y) * scale.centimetresPerPixel)
        let point = INPoint(x: x, y: y)
        return point
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public static func realCoordinates(fromPixel pixel: INPoint, scale: ObjCScale) -> INPoint {
        let x = Int32(Double(pixel.x) * scale.centimetresPerPixel)
        let y = Int32(Double(pixel.y) * scale.centimetresPerPixel)
        let point = INPoint(x: x, y: y)
        return point
    }
    
    /// Converts point given in real dimension unit to the pixel point
    ///
    /// - Parameters:
    ///   - realCoordinates: `INPoint` describing location of the point given in real dimensions, specified in `scale`.
    ///   - scale: `Scale` of the map.
    /// - Returns: `INPoint` describing location of the pixel.
    public static func pixel(fromReaCoodinates realCoordinates: INPoint, scale: Scale) -> INPoint {
        let x = Int32(Double(realCoordinates.x) / scale.centimetresPerPixel)
        let y = Int32(Double(realCoordinates.y) / scale.centimetresPerPixel)
        let point = INPoint(x: x, y: y)
        return point
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public static func pixel(fromReaCoodinates realCoordinates: INPoint, scale: ObjCScale) -> INPoint {
        let x = Int32(Double(realCoordinates.x) / scale.centimetresPerPixel)
        let y = Int32(Double(realCoordinates.y) / scale.centimetresPerPixel)
        let point = INPoint(x: x, y: y)
        return point
    }
}
