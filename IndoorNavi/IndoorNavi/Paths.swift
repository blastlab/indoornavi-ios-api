//
//  Paths.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

class Paths: NSObject {
    
    // API path
    static var indoorNaviJsPath: String {
        let bundle = Bundle(for: IndoorNavi.self)
        let path = bundle.path(forResource: "indoorNavi", ofType: "js")!
        return path
    }
    
    static var indoorNaviJsURL: URL {
        return URL(fileURLWithPath: indoorNaviJsPath)
    }
    
    // HTML Path
    static var indoorNaviHTMLPath: String {
        let bundle = Bundle(for: IndoorNavi.self)
        let path = bundle.path(forResource: "indoorNavi", ofType: "html")!
        return path
    }
    
    static var indoorNaviHtmlURL: URL {
        return URL(fileURLWithPath: indoorNaviHTMLPath)
    }
    
}
