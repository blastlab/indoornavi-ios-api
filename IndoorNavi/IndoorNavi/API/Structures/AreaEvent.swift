//
//  AreaEvent.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 07.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// Structure representing AreaEvent.
public struct AreaEvent: Equatable {
    
    /// Short ID of the tag that entered/left INArea. Value is optional.
    public var tagID: Int?
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
    init(tagID: Int? = nil, date: Date, areaID: Int, areaName: String, mode: Mode) {
        self.tagID = tagID
        self.date = date
        self.areaID = areaID
        self.areaName = areaName
        self.mode = mode
    }
    
    init?(fromJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let date = dictionary["date"] as? Date
            let tagID = dictionary["tagId"] as? Int
            let areaID = dictionary["areaId"] as? Int
            let areaName = dictionary["areaName"] as? String
            let modeString = dictionary["mode"] as? String
            let mode = modeString != nil ? AreaEvent.Mode(rawValue: modeString!) : nil
            
            if let date = date, let areaID = areaID, let areaName = areaName, let mode = mode {
                self.init(tagID: tagID, date: date, areaID: areaID, areaName: areaName, mode: mode)
                return
            }
        }
        
        return nil
    }
    
    init?(fromBleJSONObject jsonObject: Any?) {
        if let dictionary = jsonObject as? [String: Any] {
            let date = dictionary["date"] as? Date
            
            let area = dictionary["area"] as? [String: Any]
            let areaID = Int(area?["id"] as? String ?? "")
            let areaName = area?["name"] as? String
            
            let modeString = dictionary["mode"] as? String
            let mode = modeString != nil ? AreaEvent.Mode(rawValue: modeString!) : nil
            
             if let date = date, let areaID = areaID, let areaName = areaName, let mode = mode {
                self.init(tagID: nil, date: date, areaID: areaID, areaName: areaName, mode: mode)
                return
            }
        }
        
        return nil
    }
    
    init(fromObjCAreaEvent objCAreaEvent: ObjCAreaEvent) {
        let mode: Mode
        switch objCAreaEvent.mode {
        case .onLeave:
            mode = .onLeave
        case .onEnter:
            mode = .onEnter
        }
        
        self.init(tagID: objCAreaEvent.tagID, date: objCAreaEvent.date, areaID: objCAreaEvent.areaID, areaName: objCAreaEvent.areaName, mode: mode)
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
    
    convenience init(fromAreaEvent areaEvent: AreaEvent) {
        let mode: AreaEventMode
        switch areaEvent.mode {
        case .onLeave:
            mode = .onLeave
        case .onEnter:
            mode = .onEnter
        }
        
        self.init(tagID: areaEvent.tagID ?? 0, date: areaEvent.date, areaID: areaEvent.areaID, areaName: areaEvent.areaName, mode: mode)
    }
}
