//
//  ViewController.swift
//  IndoorNaviDemoDynamicFramework
//
//  Created by Michał Pastwa on 10.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import IndoorNavi
import CoreLocation

class MapViewController: UIViewController {
    
    let FrontendTargetHost = "http://172.16.170.6:4200"
    let BackendTargetHost = "http://172.16.170.6:90"
    let ApiKey = "TestAdmin"
    let BeaconUUID = "30FD7D40-2EDC-4D83-9D47-D88AA7E0492A"
    
    @IBOutlet weak var map: INMap!
    
    var marker: INMarker!
    var infoWindow: INInfoWindow!
    
    let points1: [INPoint] = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220), INPoint(x: 750, y: 750)]
    let points2: [INPoint] = [INPoint(x: 2000, y: 2000), INPoint(x: 2500, y: 2000), INPoint(x: 3000, y: 2000), INPoint(x: 3000, y: 1500), INPoint(x: 2500, y: 1500)]
    
    let configurations = [INBeaconConfiguration(x: 32.12, y: 2.46, z: 3, txPower: -69, major: 65050, minor: 187),
                          INBeaconConfiguration(x: 36.81, y: 1.4, z: 3, txPower: -69, major: 65045, minor: 187),
                          INBeaconConfiguration(x: 32.2, y: 11.61, z: 3, txPower: -69, major: 65049, minor: 187),
                          INBeaconConfiguration(x: 37.49, y: 12.27, z: 3, txPower: -69, major: 65048, minor: 187),
                          
                          INBeaconConfiguration(x: 24.60, y: 8.69, z: 3, txPower: -69, major: 65051, minor: 187),
                          INBeaconConfiguration(x: 24.45, y: 1.97, z: 3, txPower: -69, major: 65044, minor: 187),
                          INBeaconConfiguration(x: 29.91, y: 1.97, z: 3, txPower: -69, major: 65052, minor: 187),
                          INBeaconConfiguration(x: 29.91, y: 9.09, z: 3, txPower: -69, major: 65043, minor: 187),
                          
                          INBeaconConfiguration(x: 34.61, y: 14.59, z: 3, txPower: -69, major: 65047, minor: 187),
                          INBeaconConfiguration(x: 24.34, y: 14.41, z: 3, txPower: -69, major: 65046, minor: 187)]
    
    let destination = INPoint(x: 2600, y: 200)
    
    var circle1: INCircle!
    var circle2: INCircle!
    var bleLocationManager: BLELocationManager?
    var navigation: INNavigation?
    var ble: INBle!
    
    var lastPosition: INPoint?
    
    var mapLoaded = false
    
    var areas = [INArea]() {
        didSet {
            for area in areas {
                area.draw()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.setupConnection(withTargetHost: FrontendTargetHost, andApiKey: ApiKey)
        load()
    }
    
    func startLocalization() {
        bleLocationManager = BLELocationManager(beaconUUID: UUID(uuidString: BeaconUUID)!, configurations: configurations, delegate: self)
        bleLocationManager!.useCLBeaconAccuracy = true
        bleLocationManager!.startUpdatingLocation()
        ble = INBle(map: self.map, targetHost: self.BackendTargetHost, floorID: 2, apiKey: self.ApiKey, bleLocationManager: self.bleLocationManager!)
        ble!.addAreaEventListener() { event in
            print("event \(event)")
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "ALERT!", message: "Marker touched!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMapNotLoadedAlert() {
        let alert = UIAlertController(title: "Error", message: "Map is not ready yet.", preferredStyle: .alert)
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
        let marker = INMarker(withMap: map, position: INPoint(x: 600, y: 600), iconPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png", label: "Tekst ABCD")
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
        map.load(2) {
            self.circle1 = INCircle(withMap: self.map)
            self.circle1.radius = 10
            self.circle1.border = INCircle.Border(width: 5, color: .blue)
            self.circle1.color = .red
            sleep(1)
            self.circle2 = INCircle(withMap: self.map)
            self.circle2.radius = 10
            self.circle2.border = INCircle.Border(width: 5, color: .green)
            self.circle2.color = .red
            
            self.mapLoaded = true
            print("Completed.")
        }
        
        map.addLongClickListener { point in
            let marker = INMarker(withMap: self.map)
            marker.setIcon(withPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png")
            marker.position = point
            marker.addEventListener {
                self.showAlert()
            }
        }
        
        map.toggleTagVisibility(withID: 10999)
    }
    
    func getComplexes() {
        map.getComplexes { complexes in
            print("Complexes: \(complexes)")
        }
    }
    
    func getPaths() {
        let data = INData(map: map, targetHost: BackendTargetHost, apiKey: ApiKey)
        data.getPaths(fromFloorWithID: 2) { paths in
            print("Paths: \(paths)")
        }
    }
    
    func navigate() {
        navigation = INNavigation(map: map, bleLocationManager: bleLocationManager)
        
        if let lastPosition = lastPosition {
            navigation!.startNavigation(from: lastPosition, to: destination, withAccuracy: 200)
        }
    }

    func getAreas() {
        let data = INData(map: map, targetHost: BackendTargetHost, apiKey: ApiKey)
        data.getAreas(fromFloorWithID: 2) { areas in
            self.areas = areas
        }
    }
    
    func didSelect(optionWithNumber optionNumber: Int) {
        guard mapLoaded else {
            showMapNotLoadedAlert()
            return
        }
        
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
        case 6:
            getComplexes()
        case 7:
            getPaths()
        case 8:
            navigate()
        case 9:
            getAreas()
        default:
            return
        }
    }
}

extension MapViewController: BLELocationManagerDelegate {
    
    func bleLocationManager(_ manager: BLELocationManager, didUpdateLocation location: INLocation) {
        guard let scale = map.scale else {
            return
        }
        
        let positionInCentimeters = scale.measure == .centimeters ? INPoint(x: Int32( (location.x * 100).rounded()), y: Int32( (location.y * 100).rounded())) : INPoint(x: Int32( (location.x * 100).rounded()), y: Int32( (location.y * 100).rounded()))
        lastPosition = positionInCentimeters
        self.circle1.position = positionInCentimeters
        self.circle1.draw()
        
        if mapLoaded {
            let positionInPixels = MapHelper.pixel(fromReaCoodinates: positionInCentimeters, scale: scale)
            map.pullToPath(point: positionInPixels, accuracy: 10000) { pixel in
                let newPositionInCentimeters = MapHelper.realCoordinates(fromPixel: pixel, scale: scale)
                self.circle2.position = newPositionInCentimeters
                self.circle2.draw()
            }
        }
    }
    
    func bleLocationManager(_ manager: BLELocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Did change authorization")
    }
}
