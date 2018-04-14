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
    public static let indoorNaviInitializationTemplate = "var navi = new IndoorNavi('%@','%@','map',{width:%f,height:%f});"
    public static let indoorNaviLoadMapTemplate = "navi.load(%i);"
    
    // WebView configuration
    public static let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
    public static let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
    public static let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
}
