//
//  Templates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 04.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

public class Constants: NSObject {
    
    // IndoorNavi map templates
    public static let indoorNaviHtml = "<html><head></head><body><div id=\"map\"></div></body><script src=\"indoorNavi.js\"></script></html>"
    public static let indoorNaviInitialization = "var navi = new IndoorNavi(\"%@\",\"%@\",\"map\",{width:%f,height:%f});"
    
}
