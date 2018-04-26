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
    var polyline1: INPolyline!
    var polyline2: INPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = self.view.frame
        frame.origin.y = frame.origin.y + 20
        frame.size.height = frame.size.height - 100
        
        map = INMap(frame: frame, targetHost: "http://192.168.1.9:4200", apiKey: "TestAdmin")
        self.view.addSubview(map)
    }
    
    @IBAction func action(_ sender: Any) {
        map.load(2)
    }
    
    @IBAction func drawPolyline1(_ sender: Any) {
        polyline1 = INPolyline(withMap: map)
        var points = [INCoordinates]()
        points.append(INCoordinates(x: 480, y: 480))
        points.append(INCoordinates(x: 1220, y: 480))
        points.append(INCoordinates(x: 1220, y: 1220))
        points.append(INCoordinates(x: 480, y: 1220))
        points.append(INCoordinates(x: 750, y: 750))
        
        polyline1.ready {
            self.polyline1.points(points)
            self.polyline1.set(lineColor: UIColor.red)
            self.polyline1.draw()
        }
    }
    
    @IBAction func drawPolyline2(_ sender: Any) {
        polyline2 = INPolyline(withMap: map)
        var points = [INCoordinates]()
        points.append(INCoordinates(x: 2000, y: 2000))
        points.append(INCoordinates(x: 2500, y: 2000))
        points.append(INCoordinates(x: 3000, y: 2000))
        points.append(INCoordinates(x: 3000, y: 1500))
        points.append(INCoordinates(x: 2500, y: 1500))
        
        polyline2.ready {
            self.polyline2.points(points)
            self.polyline2.set(lineColor: UIColor.green)
            self.polyline2.draw()
        }
    }
    
}
