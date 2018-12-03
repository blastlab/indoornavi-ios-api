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
    let BackendTargetHost = "http://172.16.170.50:90"
    let ApiKey = "TestAdmin"
    let BeaconUUID = "30FD7D40-2EDC-4D83-9D47-D88AA7E0492A"
    
    @IBOutlet weak var map: INMap!
    
    var marker: INMarker!
    var infoWindow: INInfoWindow!
    
    let points1: [INPoint] = [INPoint(x: 480, y: 480), INPoint(x: 1220, y: 480), INPoint(x: 1220, y: 1220), INPoint(x: 480, y: 1220), INPoint(x: 750, y: 750)]
    let points2: [INPoint] = [INPoint(x: 2000, y: 2000), INPoint(x: 2500, y: 2000), INPoint(x: 3000, y: 2000), INPoint(x: 3000, y: 1500), INPoint(x: 2500, y: 1500)]
    
    let configurations = [INBeaconConfiguration(x: 3212, y: 246, z: 300, txPower: -69, major: 65050, minor: 187, floorID: 3),
                          INBeaconConfiguration(x: 3681, y: 140, z: 300, txPower: -69, major: 65045, minor: 187, floorID: 3),
                          INBeaconConfiguration(x: 3220, y: 1161, z: 300, txPower: -69, major: 65049, minor: 187, floorID: 3),
                          INBeaconConfiguration(x: 3749, y: 1227, z: 300, txPower: -69, major: 65048, minor: 187, floorID: 3),
                          
                          INBeaconConfiguration(x: 2460, y: 869, z: 300, txPower: -69, major: 65051, minor: 187, floorID: 3),
                          INBeaconConfiguration(x: 2445, y: 197, z: 300, txPower: -69, major: 65044, minor: 187, floorID: 3),
                          INBeaconConfiguration(x: 2991, y: 197, z: 300, txPower: -69, major: 65052, minor: 187, floorID: 3),
                          INBeaconConfiguration(x: 2991, y: 909, z: 300, txPower: -69, major: 65043, minor: 187, floorID: 3),
                          
                          INBeaconConfiguration(x: 3461, y: 1459, z: 300, txPower: -69, major: 65047, minor: 187, floorID: 2),
                          INBeaconConfiguration(x: 2434, y: 1441, z: 300, txPower: -69, major: 65046, minor: 187, floorID: 2)]
    
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
                area.border = Border(width: 4, color: .red)
                area.addEventListener {
                    self.showAlert()
                }
                area.draw()
                print("Database ID: \(area.databaseID ?? -1)")
                let circle = INCircle(withMap: map, position: area.center, color: .red)
                circle.draw()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pulleyViewController?.displayMode = .automatic
        _ = self.pulleyViewController?.drawerContentViewController.view
    }
    
    private func setupPulley() {
        let primaryContent = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.pulleyViewController?.setPrimaryContentViewController(controller: primaryContent, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.setupConnection(withTargetHost: FrontendTargetHost, andApiKey: ApiKey)
        load()
    }
    
    func startLocalization() {
        bleLocationManager = BLELocationManager(beaconUUID: UUID(uuidString: BeaconUUID)!, configurations: configurations, delegate: self)
        bleLocationManager!.useCLBeaconAccuracy = true
        map.enableFloorChange(wtihBLELocationManager: self.bleLocationManager!)
        ble = INBle(map: self.map, targetHost: self.BackendTargetHost, floorID: 2, apiKey: self.ApiKey, bleLocationManager: self.bleLocationManager!)
        ble!.addAreaEventListener() { event in
            print("event \(event.date)")
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
    
    func showErrorAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
    
    var area: INArea!
    
    func drawArea() {
        if let area = area {
            area.addEventListener {
                self.showAlert()
            }
            area.draw()
        } else {
            area = INArea(withMap: map, points: points1, color: UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.5))
            area.addEventListener {
                self.showAlert()
            }
            area.draw()
        }
    }
    
    func placeMarker() {
        marker = INMarker(withMap: map, position: INPoint(x: 600, y: 600), iconPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png", label: "Tekst ABCD")
        marker.addEventListener {
            self.showAlert()
        }
        marker.draw()
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
        map.load(3) {
            self.circle1 = INCircle(withMap: self.map)
            self.circle1.radius = 10
            self.circle1.border = Border(width: 5, color: .blue)
            self.circle1.color = .red
            self.circle2 = INCircle(withMap: self.map)
            self.circle2.radius = 10
            self.circle2.border = Border(width: 5, color: .green)
            self.circle2.color = .red
            
            self.mapLoaded = true
            print("Completed.")
        }
        
        map.addLongClickListener { point in
            let marker = INMarker(withMap: self.map)
            marker.icon = UIImage(named: "car")
            marker.position = point
            marker.addEventListener {
                self.showAlert()
            }
            marker.draw()
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
        if let navigation = navigation {
            navigation.restartNavigation()
        } else if let lastPosition = lastPosition {
            navigation = INNavigation(map: map, bleLocationManager: bleLocationManager, delegate: self)
            navigation!.pathColor = .brown
            navigation!.startPointProperties = INNavigation.NavigationPointProperties(radius: 5, border: Border(width: 4, color: .cyan), color: .brown)
            navigation!.endPointProperties = INNavigation.NavigationPointProperties(radius: 6, border: Border(width: 10, color: .magenta), color: .darkGray)
            navigation!.startNavigation(from: lastPosition, to: destination, withAccuracy: 200)
        }
    }
    
    func stopNavigation() {
        navigation?.stopNavigation()
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
            stopNavigation()
        case 10:
            getAreas()
        case 11:
            load()
        default:
            return
        }
    }
}

extension MapViewController: BLELocationManagerDelegate {
    
    func bleLocationManager(_ manager: BLELocationManager, didUpdateLocation location: INLocation) {
        lastPosition = INPoint(x: Int32(location.x.rounded()), y: Int32(location.y.rounded()))
        self.circle1.position = lastPosition!
        self.circle1.draw()
        
        if mapLoaded {
            map.pullToPath(point: lastPosition!, accuracy: 10000) { position in
                if let position = position {
                    self.circle2.position = position
                    self.circle2.draw()
                } else {
                    print("Could not pull to path.")
                }
            }
        }
    }
    
    func bleLocationManager(_ manager: BLELocationManager, didChangeAuthorization status: INAuthorizationStatus) {
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            showNotAuthorizedAlert()
        }
    }
    
    func bleLocationManagerLeftRegion(_ manager: BLELocationManager) {
        showErrorAlert(withMessage: "User left region.")
        print("User left region.")
    }
    
    func bleLocationManagerNoBeaconsDetected(_ manager: BLELocationManager) {
        showErrorAlert(withMessage: "No beacons detected.")
        print("No beacons detected.")
    }
    
    func bleLocationManager(_ manager: BLELocationManager, didChangeFloor floorID: Int) {
        showErrorAlert(withMessage: "Did change floor: \(floorID).")
        print("Did change floor: \(floorID).")
    }
    
    func bleLocationManager(_ manager: BLELocationManager, didFailWithError error: Error) {
        showErrorAlert(withMessage: "BLE manager did fail with error: \(error.localizedDescription)")
        print("BLE manager did fail with error: \(error.localizedDescription)")
    }
    
    func bleLocationManager(_ manager: BLELocationManager, didUpdateBluetoothState state: INBluetoothState) {
        let stateString: String
        switch state {
        case .poweredOn:
            stateString = "Powered On."
        case .poweredOff:
            stateString = "Powered Off."
        case .resetting:
            stateString = "Resetting."
        case .unauthorized:
            stateString = "Unauthorized."
        case .unknown:
            stateString = "Unknown."
        case .unsupported:
            stateString = "Unsupported."
        default:
            stateString = ""
        }
        showErrorAlert(withMessage: "State: \(String(describing: stateString))")
        print("State: \(String(describing: stateString))")
    }
    
    func showNotAuthorizedAlert() {
        let alert = UIAlertController(title: "WARNING!", message: "Not authorized to use location service!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
        
extension MapViewController: INNavigationDelegate {
    
    func navigationCreated(_ navigation: INNavigation) {
        print("Navigation created.")
    }
    
    func navigationFinished(_ navigation: INNavigation) {
        print("Navigation finished.")
    }
    
    func errorOccured(in navigation: INNavigation) {
        print("Error occured in navigation.")
    }
    
    func navigationIsWorking(_ navigation: INNavigation) {
        print("Navigation is working")
    }
}
