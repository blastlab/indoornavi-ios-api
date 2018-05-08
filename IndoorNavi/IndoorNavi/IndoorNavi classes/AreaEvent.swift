//
//  AreaEvent.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 07.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing AreaEvent
public struct AreaEvent {
    
    public var tagID: Int
    public var areaID: Int
    public var date: Date
    public var areaName: String
    public var mode: Mode
    
    public enum Mode: String {
        case onLeave = "ON_LEAVE"
        case onEnter = "ON_ENTER"
    }
    
    /**
     *  Initializes AreaEvent structure.
     *
     *  - Parameters:
     *      - tagID: Short ID of the tag that entered or left given area.
     *      - date: Specifies when tag appeared in given area.
     *      - areaID: Area's ID.
     *      - areaName: Area's name.
     *      - mode: Specifies either it was entering or leaving the area.
     */
    public init(tagID: Int, date: Date, areaID: Int, areaName: String, mode: Mode) {
        self.tagID = tagID
        self.date = date
        self.areaID = areaID
        self.areaName = areaName
        self.mode = mode
    }
}
