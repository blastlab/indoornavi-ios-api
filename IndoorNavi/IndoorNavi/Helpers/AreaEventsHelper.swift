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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            
            let areaEvents = dictionaries.map { element -> AreaEvent in
                
                let dateString = element["date"] as! String
                let date = dateFormatter.date(from: dateString)
                
                let tagID = element["tagId"] as! Int
                let areaID = element["areaId"] as! Int
                let areaName = element["areaName"] as! String
                let mode = element["mode"]! as! AreaEvent.Mode
                
                return AreaEvent(tagID: tagID, date: date!, areaID: areaID, areaName: areaName, mode: mode)
            }
            
            return areaEvents
        } else {
            return [AreaEvent]()
        }
    }
}
