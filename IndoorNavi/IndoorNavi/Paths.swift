//
//  Paths.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

public class Paths: NSObject {
    
    // API path
    public static var indoorNaviPath: String? {
        let bundle = Bundle(for: IndoorNavi.self)
        if let path = bundle.path(forResource: "indoorNavi", ofType: "js") {
            print("Path: ",path)
            return path
        } else {
            print("Path error")
            return nil
        }
    }
    
}
