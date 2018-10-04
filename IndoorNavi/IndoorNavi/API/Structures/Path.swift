//
//  Path.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing a path.
public struct Path {
    
    /// Point, at which `Path` starts.
    public var startPoint: INPoint
    /// Point, at which `Path` ends.
    public var endPoint: INPoint
    
    /// Initializes a new `Path` with the provided parameters.
    ///
    /// - Parameters:
    ///   - startPoint: Point, at which `Path` starts.
    ///   - endPoint: Point, at which `Path` ends.
    init(startPoint: INPoint, endPoint: INPoint) {
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any], let startPoint = dictionary["startPoint"], let endPoint = dictionary["endPoint"] {
            let startPoint = INPoint(fromJSONObject: startPoint)
            let endPoint = INPoint(fromJSONObject: endPoint)
            
            if let startPoint = startPoint, let endPoint = endPoint {
                self.init(startPoint: startPoint, endPoint: endPoint)
                return
            }
        }

        return nil
    }
}
