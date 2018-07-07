//
//  Scale.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04.07.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing a Scale.
public struct Scale: Equatable {
    
    /// Scale unit.
    public var measure: Measure
    /// Actual distance between `start` and `stop` points given in proper unit.
    public var realDistance: Int
    /// `INPoint` representing starting point of the set scale given in pixels.
    public var start: INPoint
    /// `INPoint` representing end point of the set scale given in pixels.
    public var stop: INPoint
    
    /// Unit of length.
    ///
    /// - centimeters: Centimetre unit of length.
    /// - meters: Metre unit of length.
    public enum Measure: String {
        case centimeters = "CENTIMETERS"
        case meters = "METERS"
    }
    
    /// Initializes `Scale` object with the provided parameters.
    ///
    /// - Parameters:
    ///   - measure: Scale measure unit.
    ///   - realDistance: Actual distance between `start` and `stop` point, given in proper unit.
    ///   - start: `INPoint` representing starting point of the set scale given in pixels
    ///   - stop: `INPoint` representing end point of the set scale given in pixels
    public init(measure: Measure, realDistance: Int, start: INPoint, stop: INPoint) {
        self.measure = measure
        self.realDistance = realDistance
        self.start = start
        self.stop = stop
    }
    
    /// Length between `start` and `stop` points
    public var scaleInPixels: Double {
        let dx = Double(start.x - stop.x)
        let dy = Double(start.y - stop.y)
        
        return (dx*dx + dy*dy).squareRoot()
    }
    
    /// Real distance length corresponding to one pixel on map
    public var centimetresPerPixel: Double {
        return Double(realDistance) / scaleInPixels
    }
    
    init?(fromJSONObject jsonObject: Any) {
        if let dictionary = jsonObject as? [String: Any], let scaleDictionary = dictionary["scale"] as? [String: Any] {
            let measureString = scaleDictionary["measure"] as? String
            let measure = measureString != nil ? Scale.Measure(rawValue: measureString!) : nil
            let realDistance = scaleDictionary["realDistance"] as? Int
            let start = PointHelper.point(fromJSONObject: scaleDictionary["start"])
            let stop = PointHelper.point(fromJSONObject: scaleDictionary["stop"])
            
            if let measure = measure, let realDistance = realDistance, let start = start, let stop = stop {
                self.init(measure: measure, realDistance: realDistance, start: start, stop: stop)
                return
            }
        }
        
        return nil
    }
}

@objc(Scale) final public class ObjCScale: NSObject {
    
    @objc public var measure: Measure
    @objc public var realDistance: Int
    @objc public var start: INPoint
    @objc public var stop: INPoint
    
    @objc public enum Measure: Int {
        case centimeters
        case meters
    }
    
    @objc public init(measure: Measure, realDistance: Int, start: INPoint, stop: INPoint) {
        self.measure = measure
        self.realDistance = realDistance
        self.start = start
        self.stop = stop
    }
    
    @objc public var scaleInPixels: Double {
        let dx = Double(start.x - stop.x)
        let dy = Double(start.y - stop.y)
        
        return (dx*dx + dy*dy).squareRoot()
    }
    
    @objc public var centimetresPerPixel: Double {
        return Double(realDistance) / scaleInPixels
    }
    
    convenience init(fromScale scale: Scale) {
        let measure: Measure
        
        switch scale.measure {
        case .centimeters:
            measure = .centimeters
        case .meters:
            measure = .meters
        }
        self.init(measure: measure, realDistance: scale.realDistance, start: scale.start, stop: scale.stop)
    }
}
