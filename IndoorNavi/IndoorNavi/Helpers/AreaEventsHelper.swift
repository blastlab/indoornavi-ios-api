//
//  AreaEventHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 08.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class AreaEventsHelper: NSObject {
    
    static func areaEvents(fromJSONObject jsonObject: Any?) -> [AreaEvent] {
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
    
    static func callbackHandlerTakingStructs(fromCallbackHandlerTakingObjects callbackHandlerTakingObjects: @escaping ([ObjCAreaEvent]) -> Void) -> ([AreaEvent]) -> Void {
        let callbackHandlerTakingStructs: ([AreaEvent]) -> Void = { areaEvents in
            let objCAreaEvents: [ObjCAreaEvent] = areaEvents.map { areaEvent in
                
                let mode: ObjCAreaEvent.AreaEventMode
                switch areaEvent.mode {
                case .onLeave:
                    mode = .onLeave
                case .onEnter:
                    mode = .onEnter
                }
                
                let objCAreaEvent = ObjCAreaEvent(tagID: areaEvent.tagID, date: areaEvent.date, areaID: areaEvent.areaID, areaName: areaEvent.areaName, mode: mode)
                return objCAreaEvent
            }
            callbackHandlerTakingObjects(objCAreaEvents)
        }
        
        return callbackHandlerTakingStructs
    }
}
