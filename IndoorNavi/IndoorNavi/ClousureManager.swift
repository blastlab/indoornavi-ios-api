//
//  ClousureManager.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 23.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

class ClousureManager: NSObject {
    
    static var clousuresToPerform = [String: () -> Void]()
    
    static func promiseResolved(withUUID uuid: String) {
        if let clousure = clousuresToPerform[uuid] {
            clousure()
            clousuresToPerform.removeValue(forKey: uuid)
        }
    }
}
