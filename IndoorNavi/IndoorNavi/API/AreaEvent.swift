//
//  AreaEvent.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 07.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing AreaEvent.
public struct AreaEvent {
    
    /// Short ID of the tag that entered/left INArea.
    public var tagID: Int
    /// ID of the `INArea` where `AreaEvent` occured.
    public var areaID: Int
    /// Date when `AreaEvent` occured.
    public var date: Date
    /// Name of the `INArea` where `AreaEvent` occured.
    public var areaName: String
    /// Specifies `AreaEvent`'s `Mode`.
    public var mode: Mode
    
    /// Mode of `AreaEvent`.
    ///
    /// - onLeave: Event on leaving `INArea`.
    /// - onEnter: Event on entering `INArea`.
    public enum Mode: String {
        case onLeave = "ON_LEAVE"
        case onEnter = "ON_ENTER"
    }
    
    /// Initializes `AreaEvent` structure.
    ///
    /// - Parameters:
    ///   - tagID: Short ID of the tag that entered or left given area.
    ///   - date: Specifies when tag appeared in given area.
    ///   - areaID: Area's ID.
    ///   - areaName: Area's name.
    ///   - mode: Specifies either it was entering or leaving the area.
    public init(tagID: Int, date: Date, areaID: Int, areaName: String, mode: Mode) {
        self.tagID = tagID
        self.date = date
        self.areaID = areaID
        self.areaName = areaName
        self.mode = mode
    }
}

@objc(AreaEvent) final public class ObjCAreaEvent: NSObject {
    
    @objc public var tagID: Int
    @objc public var areaID: Int
    @objc public var date: Date
    @objc public var areaName: String
    @objc public var mode: AreaEventMode
    
    @objc public enum AreaEventMode: Int {
        case onLeave
        case onEnter
    }
    
    @objc public init(tagID: Int, date: Date, areaID: Int, areaName: String, mode: AreaEventMode) {
        self.tagID = tagID
        self.date = date
        self.areaID = areaID
        self.areaName = areaName
        self.mode = mode
    }
}
