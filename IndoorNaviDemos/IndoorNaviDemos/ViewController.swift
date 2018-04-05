//
//  ViewController.swift
//  IndoorNaviDemos
//
//  Created by Michał Pastwa on 29.03.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import IndoorNavi

class ViewController: UIViewController {
    
    var indoorNavi: IndoorNavi!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = self.view.frame
        frame.origin.y = frame.origin.y + 20
        frame.size.height = frame.size.height - 100
        
        indoorNavi = IndoorNavi(frame: frame, targetHost: "http://192.168.1.2:4200", apiKey: "TestAdmin")
        self.view.addSubview(indoorNavi)
        
    }

    @IBAction func action(_ sender: Any) {
        indoorNavi.load(2)
    }
}

