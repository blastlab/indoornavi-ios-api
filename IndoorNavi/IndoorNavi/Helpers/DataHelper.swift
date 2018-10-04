//
//  DataHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04/10/2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

class DataHelper: NSObject {
    
    static func paths(fromJSONObject jsonObject: Any?) -> [Path] {
        if let pathsDictionaries = jsonObject as? [[String: Any]] {
            
            let paths = pathsDictionaries.compactMap { element -> Path? in
                let path = Path(fromJSONObject: element)
                return path
            }
            
            return paths
        } else {
            return [Path]()
        }
    }
}
