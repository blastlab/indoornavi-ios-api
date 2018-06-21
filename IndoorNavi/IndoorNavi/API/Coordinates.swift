//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing Coordinates, registered on specific `date` for specific tag with `tagID`.
public struct Coordinates {
    
    /// The x-coordinate coordinate in centimiters
    public var x: Int
    /// The y-coordinate coordinate in centimiters
    public var y: Int
    /// Short ID of the tag.
    public var tagID: Int
    /// Date of `Coordinates` registration.
    public var date: Date
    
    /// Initializes `Coordinates` structure.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate coordinate in centimiters
    ///   - y: The y-coordinate coordinate in centimiters
    ///   - tagID: Short ID of the tag.
    ///   - date: Date of `Coordinates` registration.
    public init(x: Int, y: Int, tagID: Int, date: Date) {
        self.x = x
        self.y = y
        self.tagID = tagID
        self.date = date
    }
}

@objc(Coordinates) final public class _ObjCCoordinates: NSObject {
    
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
}
