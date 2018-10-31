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
            assertionFailure("Could not initialize array of AreaEvent's from JSON object.")
            return [AreaEvent]()
        }
    }
    
    static func bleAreaEvents(fromJSONObject jsonObject: Any?) -> [AreaEvent] {
        if let dictionaries = jsonObject as? [[String: Any]] {
            
            let bleAreaEvents = dictionaries.compactMap { element -> AreaEvent? in
                let areaEvent = AreaEvent(fromBleJSONObject: element)
                return areaEvent
            }
            
            return bleAreaEvents
        } else {
            assertionFailure("Could not initialize arrat of AreaEvent's from JSON object.")
            return [AreaEvent]()
        }
    }
    
    static func callbackHandlerTakingStruct(fromCallbackHandlerTakingObject callbackHandlerTakingObject: @escaping (ObjCAreaEvent) -> Void) -> (AreaEvent) -> Void {
        let callbackHandlerTakingStruct: (AreaEvent) -> Void = { areaEvent in
            let objCAreaEvent = ObjCAreaEvent(fromAreaEvent: areaEvent)
            callbackHandlerTakingObject(objCAreaEvent)
        }
        return callbackHandlerTakingStruct
    }
    
    static func callbackHandlerTakingStructs(fromCallbackHandlerTakingObjects callbackHandlerTakingObjects: @escaping ([ObjCAreaEvent]) -> Void) -> ([AreaEvent]) -> Void {
        let callbackHandlerTakingStructs: ([AreaEvent]) -> Void = { areaEvents in
            let objCAreaEvents: [ObjCAreaEvent] = areaEvents.map { areaEvent in
                let objCAreaEvent = ObjCAreaEvent(fromAreaEvent: areaEvent)
                return objCAreaEvent
            }
            callbackHandlerTakingObjects(objCAreaEvents)
        }
        
        return callbackHandlerTakingStructs
    }
}
