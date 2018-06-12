//
//  AreaEventHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 08.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class AreaEventsHelper: NSObject {
    
    static func areaEvents(fromJSONObject jsonObject: Any) -> [AreaEvent] {
        if let dictionaries = jsonObject as? [[String: Any]] {
            
            let areaEvents = dictionaries.compactMap { element -> AreaEvent? in
                
                let date = element["date"] as? Date
                let tagID = element["tagId"] as? Int
                let areaID = element["areaId"] as? Int
                let areaName = element["areaName"] as? String
                let modeString = element["mode"] as? String
                let mode = modeString != nil ? AreaEvent.Mode(rawValue: modeString!) : nil
                
                if let date = date, let tagID = tagID, let areaID = areaID, let areaName = areaName, let mode = mode {
                    return AreaEvent(tagID: tagID, date: date, areaID: areaID, areaName: areaName, mode: mode)
                } else {
                    return nil
                }
            }
            
            return areaEvents
        } else {
            return [AreaEvent]()
        }
    }
}
