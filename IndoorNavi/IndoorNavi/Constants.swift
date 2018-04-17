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
    public static let indoorNaviInitializationTemplate = "var navi = new IndoorNavi('%@','%@','map',{width:document.body.clientWidth,height:document.body.clientHeight});"
    public static let indoorNaviLoadMapTemplate = "navi.load(%i);"
    
    // WebView configuration
    public static let viewportScriptString = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
    public static let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
    public static let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
}
