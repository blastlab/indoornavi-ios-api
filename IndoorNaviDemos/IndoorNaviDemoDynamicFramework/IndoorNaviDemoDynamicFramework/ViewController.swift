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
    
    let FrontendTargetHost = "http://172.16.170.51:4200"
    let BackendTargetHost = "http://172.16.170.51:90"
    let ApiKey = "TestAdmin"
    
    var map: INMap!
    var marker: INMarker!
    
    let points1: [Point] = [Point(x: 480, y: 480), Point(x: 1220, y: 480), Point(x: 1220, y: 1220), Point(x: 480, y: 1220), Point(x: 750, y: 750)]
    let points2: [Point] = [Point(x: 2000, y: 2000), Point(x: 2500, y: 2000), Point(x: 3000, y: 2000), Point(x: 3000, y: 1500), Point(x: 2500, y: 1500)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = self.view.frame
        frame.origin.y = frame.origin.y + 20
        frame.size.height = frame.size.height - 150
        
        map = INMap(frame: frame, targetHost: FrontendTargetHost, apiKey: ApiKey)
        self.view.addSubview(map)
        map.load(2) {
            print("Completed.")
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "ALERT!", message: "Marker touched!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func drawInfoWindow(_ sender: Any) {
        let infoWindow = INInfoWindow(withMap: map)
        
        infoWindow.setInnerHTML(string: "<h2>Lorem ipsum dolor sit amet</h2>")
        infoWindow.position = .top
        infoWindow.height = 49
        infoWindow.width = 5
        infoWindow.open(object: self.marker)
    }
    
    @IBAction func drawPolyline1(_ sender: Any) {
        let polyline1 = INPolyline(withMap: map)
        
        polyline1.points(self.points1)
        polyline1.set(red: 1.0, green: 0.5, blue: 0.5)
        polyline1.draw()
        
        print("Polyline 1 ID: %d", polyline1.objectID != nil ? polyline1.objectID! : 0)
        
        polyline1.getPoints { coordinates in
            print("Coordinates: \(String(describing: coordinates != nil ? coordinates : nil))")
        }
    }
    
    @IBAction func drawPolyline2(_ sender: Any) {
        let polyline2 = INPolyline(withMap: map)
        
        polyline2.points(self.points2)
        polyline2.set(red: 0.5, green: 1.0, blue: 0.5)
        polyline2.draw()
        
        print("Polyline 2 ID: %d", polyline2.objectID != nil ? polyline2.objectID! : 0)
    }
    
    @IBAction func drawArea(_ sender: Any) {
        let area = INArea(withMap: map)
        
        area.points(self.points1)
        area.setFillColor(red: 0.8, green: 0.4, blue: 0.2)
        area.setOpacity(0.5)
        area.draw()
    }
    
    @IBAction func placeMarker(_ sender: Any) {
        marker = INMarker(withMap: map)
        
        marker.point(Point(x: 600, y: 600))
        marker.setIcon(withPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png")
        marker.setLabel(withText: "Tekst ABCD")
        marker.addEventListener {
            self.showAlert()
        }
        marker.draw()
    }
    @IBAction func createReport(_ sender: Any) {
        let report = INReport(map: map, targetHost: BackendTargetHost, apiKey: ApiKey)
        report.getAreaEvents(fromFloorWithID: 2, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { areaEvents in
            print("Area events: ", areaEvents)
        }
        
        report.getCoordinates(fromFloorWithID: 2, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { coordinates in
            print("Coordinates: ", coordinates)
        }
    }
    
    @IBAction func getCoordinates(_ sender: Any) {
        
    }
}
