//
//  ViewController.swift
//  IndoorNaviDemoDynamicFramework
//
//  Created by Michał Pastwa on 10.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import IndoorNavi

let FrontendTargetHost = "http://172.16.170.33:4200"
let BackendTargetHost = "http://172.16.170.33:90"
let ApiKey = "TestAdmin"

class ViewController: UIViewController {
    
    @IBOutlet weak var map: INMap!
    var marker: INMarker!
    var infoWindow: INInfoWindow!
    var deviceID: Int?
    let connection = Connection(targetHost: BackendTargetHost, apiKey: ApiKey)
    
    let points1: [INPoint] = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220), INPoint(x: 750, y: 750)]
    let points2: [INPoint] = [INPoint(x: 2000, y: 2000), INPoint(x: 2500, y: 2000), INPoint(x: 3000, y: 2000), INPoint(x: 3000, y: 1500), INPoint(x: 2500, y: 1500)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.setupConnection(withTargetHost: FrontendTargetHost, andApiKey: ApiKey)
        self.view.addSubview(map)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "ALERT!", message: "Marker touched!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func drawInfoWindow(_ sender: Any) {
        placeMarker(sender)
        infoWindow = INInfoWindow(withMap: self.map, width: Int(arc4random_uniform(220) + 30), height: Int(arc4random_uniform(220) + 30), position: .bottomLeft, content: "<h2>Lorem ipsum dolor sit amet</h2>")
        marker.add(infoWindow: infoWindow)
    }
    
    @IBAction func drawPolyline1(_ sender: Any) {
        let polyline = INPolyline(withMap: map)
        polyline.points = points1
        polyline.color = .green
        polyline.draw()

        print("Polyline 1 ID: %d", polyline.objectID != nil ? polyline.objectID! : 0)
    }
    
    @IBAction func registerPhone(_ sender: Any) {
        connection.registerDevice(withUserData: "ABCD") { id, error in
            self.deviceID = id
            print("ID: \(id != nil ? String(describing: id!) : "nil")")
        }
    }
    
    @IBAction func drawArea(_ sender: Any) {
        let area = INArea(withMap: map, points: points1, color: UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.5))
        area.draw()
    }
    
    @IBAction func placeMarker(_ sender: Any) {
        marker = INMarker(withMap: map, position: INPoint(x: 600, y: 600), iconPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png", label: "Tekst ABCD")
        marker.addEventListener {
            self.showAlert()
        }
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
        print("infoWindow id \(String(describing: infoWindow.objectID))")
    }
    
    @IBAction func sendCoordinates(_ sender: Any) {
        if let deviceID = deviceID {
            connection.send([CGPoint(x: 500, y: 500)], date: Date(), floorID: 2, deviceID: deviceID) { error in
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func drawCircle(_ sender: Any) {
        let color = UIColor.red
        let circle = INCircle(withMap: map, position: INPoint(x: 700, y: 700), color: color)
        circle.radius = 10
        circle.border = INCircle.Border(width: 5, color: .blue)
        circle.draw()
    }
    
    @IBAction func load(_ sender: Any) {
        map.load(2) {
            print("Completed.")
        }
        
        map.addLongClickListener { point in
            let marker = INMarker(withMap: self.map)
            marker.setIcon(withPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png")
            let pointWithRealCoordinates = MapHelper.realCoordinates(fromPixel: point, scale: self.map.scale!)
            marker.position = pointWithRealCoordinates
            marker.draw()
        }
        
        map.toggleTagVisibility(withID: 10999)
    }
}
