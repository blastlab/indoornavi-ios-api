//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing Coordinates, registered on specific `date` for specific tag with `tagID`.
public struct Coordinates {
    
    /// Vertical coordinate in centimiters
    public var x: Int
    /// Horizontal coordinate in centimiters
    public var y: Int
    /// Short ID of the tag.
    public var tagID: Int
    /// Date of `Coordinates` registration.
    public var date: Date
    
    /**
     *  Initializes `Coordinates` structure.
     *
     *  - Parameters:
     *      - x: Short ID of the tag that entered or left given area.
     *      - y: Specifies when tag appeared in given area.
     *      - tagID: Area's ID.
     *      - date: Area's name.
     */
    public init(x: Int, y: Int, tagID: Int, date: Date) {
        self.x = x
        self.y = y
        self.tagID = tagID
        self.date = date
    }
}

/// Class representing Coordinates, registered on specific `date` for specific tag with `tagID`.
@objc(Coordinates) final public class _ObjCCoordinates: NSObject {
    
    /// Vertical coordinate in centimiters
    public var x: Int
    /// Horizontal coordinate in centimiters
    public var y: Int
    /// Short ID of the tag.
    public var tagID: Int
    /// Date of `Coordinates` registration.
    public var date: Date
    
    /**
     *  Initializes `Coordinates` object.
     *
     *  - Parameters:
     *      - x: Short ID of the tag that entered or left given area.
     *      - y: Specifies when tag appeared in given area.
     *      - tagID: Area's ID.
     *      - date: Area's name.
     */
    public init(x: Int, y: Int, tagID: Int, date: Date) {
        self.x = x
        self.y = y
        self.tagID = tagID
        self.date = date
    }
}
