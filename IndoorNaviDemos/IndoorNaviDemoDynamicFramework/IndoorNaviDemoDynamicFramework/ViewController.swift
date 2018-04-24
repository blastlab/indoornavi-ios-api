//
//  ViewController.swift
//  IndoorNaviDemoDynamicFramework
//
//  Created by Michał Pastwa on 10.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import IndoorNavi

class ViewController: UIViewController {
    
    var map: INMap!
    var polyline: INPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = self.view.frame
        frame.origin.y = frame.origin.y + 20
        frame.size.height = frame.size.height - 100
        
        map = INMap(frame: frame, targetHost: "http://192.168.1.12:4200", apiKey: "TestAdmin")
        self.view.addSubview(map)
    }
    
    @IBAction func action(_ sender: Any) {
        map.load(2)
    }
    
    @IBAction func drawPolyline(_ sender: Any) {
        polyline = INPolyline(withMap: map)
    }
    
    @IBAction func action3(_ sender: Any) {
        var points = [INCoordinates]()
        points.append(INCoordinates(x: 480, y: 480))
        points.append(INCoordinates(x: 1220, y: 480))
        points.append(INCoordinates(x: 1220, y: 1220))
        points.append(INCoordinates(x: 480, y: 1220))
        points.append(INCoordinates(x: 750, y: 750))
        
        polyline.ready {
            self.polyline.points(points)
            self.polyline.set(lineColor: UIColor.red)
            self.polyline.draw()
        }
    }
}
