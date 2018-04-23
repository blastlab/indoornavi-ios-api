//
//  WebViewScrollViewDelegate.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 14.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

class NativeWebViewScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    static var shared = NativeWebViewScrollViewDelegate()
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
}
