//
//  CoordinatesHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class CoordinatesHelper: NSObject {
    
    static func coordinatesArray(fromJSONObject jsonObject: Any) -> [Coordinates] {
        if let dictionaries = jsonObject as? [[String: Any]] {
            
            let coordinatesArray = dictionaries.compactMap { element -> Coordinates? in
                
                let x = element["x"] as? Int
                let y = element["y"] as? Int
                let tagID = element["tagId"] as? Int
                let date = element["date"] as? Date
                
                if let x = x, let y = y, let tagID = tagID, let date = date {
                    return Coordinates(x: x, y: y, tagID: tagID, date: date)
                } else {
                    return nil
                }
            }
            
            return coordinatesArray
        } else {
            return [Coordinates]()
        }
    }
}
