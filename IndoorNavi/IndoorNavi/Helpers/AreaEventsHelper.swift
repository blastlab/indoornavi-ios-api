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
                let areaEvent = AreaEvent(fromJSONObject: element)
                return areaEvent
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
