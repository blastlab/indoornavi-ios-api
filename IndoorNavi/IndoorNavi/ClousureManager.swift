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
        print("Resolving promise with UUID: \(uuid)...")
        
        print("Clousures in dictionary:")
        for clousure in clousuresToPerform {
            print("- \(clousure)")
        }
        
        if let clousure = clousuresToPerform[uuid] {
            print("Clousure found.")
            clousure()
            clousuresToPerform.removeValue(forKey: uuid)
        }
        
        print("Clousures in dictionary after applying:")
        for clousure in clousuresToPerform {
            print("- \(clousure)")
        }
    }
}
