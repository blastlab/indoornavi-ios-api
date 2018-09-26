//
//  ViewController.swift
//  IndoorNaviDemoDynamicFramework
//
//  Created by Michał Pastwa on 10.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import IndoorNavi

class MapViewController: UIViewController {
    
    let FrontendTargetHost = "http://172.16.170.20:4200"
    let BackendTargetHost = "http://172.16.170.20:90"
    let ApiKey = "TestAdmin"
    let BeaconUUID = "30FD7D40-2EDC-4D83-9D47-D88AA7E0492A"
    
    @IBOutlet weak var map: INMap!
    
    var marker: INMarker!
    var infoWindow: INInfoWindow!
    
    let points1: [INPoint] = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220), INPoint(x: 750, y: 750)]
    let points2: [INPoint] = [INPoint(x: 2000, y: 2000), INPoint(x: 2500, y: 2000), INPoint(x: 3000, y: 2000), INPoint(x: 3000, y: 1500), INPoint(x: 2500, y: 1500)]
    
    let configurations = [INBeaconConfiguration(x: 24.45, y: 1.97, z: 3, txPower: -69, major: 65012, minor: 187),
                          INBeaconConfiguration(x: 29.91, y: 1.94, z: 3, txPower: -69, major: 65018, minor: 187),
                          INBeaconConfiguration(x: 24.6, y: 8.69, z: 3, txPower: -69, major: 65016, minor: 187),
                          INBeaconConfiguration(x: 29.91, y: 9.09, z: 3, txPower: -69, major: 65019, minor: 187),
                          
                          INBeaconConfiguration(x: 32.12, y: 2.46, z: 3, txPower: -69, major: 65014, minor: 187),
                          INBeaconConfiguration(x: 36.81, y: 1.4, z: 3, txPower: -69, major: 65008, minor: 187),
                          INBeaconConfiguration(x: 32.2, y: 11.61, z: 3, txPower: -69, major: 65021, minor: 187),
                          INBeaconConfiguration(x: 37.49, y: 12.27, z: 3, txPower: -69, major: 65007, minor: 187),
                          
                          INBeaconConfiguration(x: 34.61, y: 14.59, z: 3, txPower: -69, major: 65015, minor: 187),
                          INBeaconConfiguration(x: 24.34, y: 14.41, z: 3, txPower: -69, major: 65011, minor: 187),
                          INBeaconConfiguration(x: 16.82, y: 14.44, z: 3, txPower: -69, major: 65017, minor: 187),
                          
                          INBeaconConfiguration(x: 1.17, y: 17.42, z: 3, txPower: -69, major: 65020, minor: 187),
                          INBeaconConfiguration(x: 7.6, y: 16.44, z: 3, txPower: -69, major: 65003, minor: 187),
                          INBeaconConfiguration(x: 1.26, y: 22.88, z: 3, txPower: -69, major: 65006, minor: 187),
                          INBeaconConfiguration(x: 7, y: 23.22, z: 3, txPower: -69, major: 65009, minor: 187)]
    
    var circle: INCircle!
    var bleLocationManager: BLELocationManager?
    
    var mapLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.setupConnection(withTargetHost: FrontendTargetHost, andApiKey: ApiKey)
        load()
//        self.view.addSubview(map)
    }
    
    func startLocalization() {
        bleLocationManager = BLELocationManager(beaconUUID: UUID(uuidString: BeaconUUID)!, configurations: configurations, delegate: self)
        bleLocationManager!.useCLBeaconAccuracy = true
        bleLocationManager!.startUpdatingLocation()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "ALERT!", message: "Marker touched!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func drawInfoWindow() {
        placeMarker()
        infoWindow = INInfoWindow(withMap: self.map, width: Int(arc4random_uniform(220) + 30), height: Int(arc4random_uniform(220) + 30), position: .bottomLeft, content: "<h2>Lorem ipsum dolor sit amet</h2>")
        marker.add(infoWindow: infoWindow)
    }
    
    func drawPolyline1() {
        let polyline = INPolyline(withMap: map)
        polyline.points = points1
        polyline.color = .green
        polyline.draw()

        print("Polyline 1 ID: %d", polyline.objectID != nil ? polyline.objectID! : 0)
    }
    
    func drawPolyline2() {
        let polyline = INPolyline(withMap: map, points: points2, color: .brown)
        polyline.draw()
        print("Polyline 2 ID: %d", polyline.objectID != nil ? polyline.objectID! : 0)
    }
    
    func drawArea() {
        let area = INArea(withMap: map, points: points1, color: UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.5))
        area.draw()
    }
    
    func placeMarker() {
        marker = INMarker(withMap: map, position: INPoint(x: 600, y: 600), iconPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png", label: "Tekst ABCD")
        marker.addEventListener {
            self.showAlert()
        }
    }
    
    func createReport() {
        let report = INReport(map: map, targetHost: BackendTargetHost, apiKey: ApiKey)
        report.getAreaEvents(fromFloorWithID: 2, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { areaEvents in
            print("Area events: ", areaEvents)
        }
        
        report.getCoordinates(fromFloorWithID: 2, from: Date(timeIntervalSince1970: 1428105600), to: Date()) { coordinates in
            print("Coordinates: ", coordinates)
        }
    }
    
    func load() {
        map.load(1) {
            self.circle = INCircle(withMap: self.map)
            self.circle.radius = 10
            self.circle.border = INCircle.Border(width: 5, color: .blue)
            self.circle.color = .red
            self.mapLoaded = true
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
    
    func didSelect(optionWithNumber optionNumber: Int) {
        switch optionNumber {
        case 0:
            drawArea()
        case 1:
            drawInfoWindow()
        case 2:
            startLocalization()
        case 3:
            placeMarker()
        case 4:
            drawPolyline1()
        case 5:
            createReport()
        default:
            return
        }
    }
}

extension MapViewController: BLELocationManagerDelegate {
    
    func bleLocationManager(_ manager: BLELocationManager, didUpdateLocation location: INLocation) {
        print("Location: (x: \(location.x), y: \(location.y))")
        if mapLoaded {
            circle.position = INPoint(x: Int32((location.x * 100).rounded()), y: Int32((location.y * 100).rounded()))
            circle.draw()
        }
        
    }
}
