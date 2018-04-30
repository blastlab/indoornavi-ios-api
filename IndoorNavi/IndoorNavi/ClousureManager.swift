//
//  ClousureManager.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 23.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

class ClousureManager: NSObject {
    
    static var promises = [String: () -> Void]()
    static var eventCallbacks = [String: () -> Void]()
    
    static func receivedUUID(_ uuid: String) {
        if let clousure = promises[uuid] {
            clousure()
            promises.removeValue(forKey: uuid)
        } else if let clousure = eventCallbacks[uuid] {
            clousure()
        }
    }
    
    static func removeEventCallback(forUUID uuid: String) {
        eventCallbacks.removeValue(forKey: uuid)
    }
}
