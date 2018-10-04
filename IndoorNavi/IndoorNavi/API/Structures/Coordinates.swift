//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing Coordinates, registered on specific `date` for specific tag with `tagID`.
public struct Coordinates: Equatable {
    
    /// The x-coordinate in centimiters
    public var x: Int
    /// The y-coordinate in centimiters
    public var y: Int
    /// Short ID of the tag.
    public var tagID: Int
    /// Date of `Coordinates` registration.
    public var date: Date
    
    /// Initializes `Coordinates` structure.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate in centimiters
    ///   - y: The y-coordinate in centimiters
    ///   - tagID: Short ID of the tag.
    ///   - date: Date of `Coordinates` registration.
    init(x: Int, y: Int, tagID: Int, date: Date) {
        self.x = x
        self.y = y
        self.tagID = tagID
        self.date = date
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let x = dictionary["x"] as? Int
            let y = dictionary["y"] as? Int
            let tagID = dictionary["tagId"] as? Int
            let date = dictionary["date"] as? Date
            
            if let x = x, let y = y, let tagID = tagID, let date = date {
                self.init(x: x, y: y, tagID: tagID, date: date)
                return
            }
        }
        
        return nil
    }
    
    init(fromObjCCoordinates objCCoordinates: ObjCCoordinates) {
        self.init(x: objCCoordinates.x, y: objCCoordinates.y, tagID: objCCoordinates.tagID, date: objCCoordinates.date)
    }
}

@objc(Coordinates) final public class ObjCCoordinates: NSObject {
    
    @objc public var x: Int
    @objc public var y: Int
    @objc public var tagID: Int
    @objc public var date: Date
    
    @objc public init(x: Int, y: Int, tagID: Int, date: Date) {
        self.x = x
        self.y = y
        self.tagID = tagID
        self.date = date
    }
    
    convenience init(fromCoordinates coordinates: Coordinates) {
        self.init(x: coordinates.x, y: coordinates.y, tagID: coordinates.tagID, date: coordinates.date)
    }
}
