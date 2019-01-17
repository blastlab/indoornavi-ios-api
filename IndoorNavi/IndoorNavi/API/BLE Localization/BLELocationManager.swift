//
//  BLELocationManager.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28.08.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import CoreLocation

let NumberOfFloorMeasurements = 3

extension Notification.Name {
    static let didUpdateLocation = Notification.Name("didUpdateLocation")
    static let didChangeFloor = Notification.Name("didChangeFloor")
}

/// Structure representing information about a detected iBeacon, its configuration and location.
public struct INBeacon {
    /// Information about a detected iBeacon.
    public var beacon: CLBeacon
    /// Configuration of iBeacon, describing its coordinates, major, minor and txPower.
    public var configuration: INBeaconConfiguration
    /// Location of iBeacon.
    public var location: INLocation {
        return INLocation(x: configuration.x, y: configuration.y)
    }
}

/// Configuration of iBeacon, describing its coordinates, major, minor and txPower.
public struct INBeaconConfiguration {
    /// The x-coordinate of the iBeacon in centimeters.
    var x: Double
    /// The y-coordinate of the iBeacon in centimeters.
    var y: Double
    /// The z-coordinate of the iBeacon in centimeters.
    var z: Double
    /// The most significant value in the beacon.
    var major: Int
    /// The least significant value in the beacon.
    var minor: Int
    /// The one-meter RSSI level.
    var txPower: Int
    /// ID of the floor, where iBeacon is placed.
    var floorID: Int
    
    /// Initializes a new `INBeaconConfiguration` with the provided parameters.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the iBeacon in centimeters.
    ///   - y: The y-coordinate of the iBeacon in centimeters.
    ///   - z: The z-coordinate of the iBeacon in centimeters.
    ///   - txPower: The one-meter RSSI level.
    ///   - major: The most significant value in the beacon.
    ///   - minor: The least significant value in the beacon.
    ///   - floorID: ID of the floor, where iBeacon is placed.
    public init(x: Double, y: Double, z: Double, txPower: Int, major: Int, minor: Int, floorID: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.major = major
        self.minor = minor
        self.txPower = txPower
        self.floorID = floorID
    }
}

/// The methods that you use to receive events about current location.
public protocol BLELocationManagerDelegate {
    
    /// Tells the delegate that new location data is available.
    ///
    /// - Parameters:
    ///   - manager: The object that you use to start and stop the delivery of location events to your app.
    ///   - location: The XY coordinates representing current location in centimeters.
    func bleLocationManager(_ manager: BLELocationManager, didUpdateLocation location: INLocation)
    
    /// Tells the delegate that the authorization status for the application changed.
    ///
    /// - Parameters:
    ///   - manager: The object that you use to start and stop the delivery of location events to your app.
    ///   - status: The new authorization status for the application.
    func bleLocationManager(_ manager: BLELocationManager, didChangeAuthorization status: INAuthorizationStatus)
    
    /// Tells the delegate that the bluetooth state changed.
    ///
    /// - Parameters:
    ///   - manager: The object that you use to start and stop the delivery of location events to your app.
    ///   - state: State of the Bluetooth.
    func bleLocationManager(_ manager: BLELocationManager, didUpdateBluetoothState state: INBluetoothState)
    
    /// Tells the delegate that an internal error occurred while getting new location data.
    ///
    /// - Parameters:
    ///   - manager: The object that you use to start and stop the delivery of location events to your app.
    ///   - error: An error object containing the error code that indicates why getting new location data failed.
    func bleLocationManager(_ manager: BLELocationManager, didFailWithError error: Error)
    
    /// Tells the delegate that an error occurred while starting location..
    ///
    /// - Parameters:
    ///   - manager: The object that you use to start and stop the delivery of location events to your app.
    ///   - localizationError: An error object containing the error code that indicates why starting localization failed.
    func bleLocationManager(_ manager: BLELocationManager, didFailWithLocalizationError localizationError: LocalizationError)
    
    /// Tells the delegate that the user left the region, where localization was set and is out of range.
    ///
    /// - Parameter manager: The object that you use to start and stop the delivery of location events to your app.
    func bleLocationManagerLeftRegion(_ manager: BLELocationManager, withLatestKnownLocation location: INLocation)
    
    /// Tells the delegate that no beacon device was detected. The method is called every time the `BLELocationManager` tries to get new location data.
    ///
    /// - Parameter manager: The object that you use to start and stop the delivery of location events to your app.
    func bleLocationManagerNoBeaconsDetected(_ manager: BLELocationManager)
    
    /// Tells the delegate that the user moved to other floor.
    ///
    /// - Parameters:
    ///   - manager: The object that you use to start and stop the delivery of location events to your app.
    ///   - floorID: Current floor ID estimated by BLE localization.
    func bleLocationManager(_ manager: BLELocationManager, didChangeFloor floorID: Int)
    
    /// Tells the delegate about three nearest beacons that are in range, their `accuracy`'s are known and corresponding `INBeaconConfiguration`'s were found. These beacons are used to calculate `INLocation`.
    ///
    /// - Parameter beacons: Array of ranged beacons, with corresponding `INBeaconConfiguration`.
    func bleLocationManager(_ manager: BLELocationManager, didRangeBeacons beacons: [INBeacon])
    
    /// Tells the delegate about all of the beacons that are in range, no matter if they were specified in configuration or not. This method can be used to get debug information.
    ///
    /// - Parameter beacons: Array of all ranged beacons, that have been detected.
    func bleLocationManager(_ manager: BLELocationManager, didDetectNearbyBeacons beacons: [CLBeacon])
}

public extension BLELocationManagerDelegate {
    func bleLocationManager(_ manager: BLELocationManager, didFailWithError error: Error) {}
    func bleLocationManager(_ manager: BLELocationManager, didFailWithLocalizationError localizationError: LocalizationError) {}
    func bleLocationManagerLeftRegion(_ manager: BLELocationManager, withLatestKnownLocation location: INLocation) {}
    func bleLocationManagerNoBeaconsDetected(_ manager: BLELocationManager) {}
    func bleLocationManager(_ manager: BLELocationManager, didChangeFloor floorID: Int) {}
    func bleLocationManager(_ manager: BLELocationManager, didRangeBeacons beacons: [INBeacon]) {}
    func bleLocationManager(_ manager: BLELocationManager, didDetectNearbyBeacons beacons: [CLBeacon]) {}
}

/// The object that you use to start and stop the delivery of location events to your app based on iBeacons.
public class BLELocationManager: NSObject {
    
    /// The delegate object to receive update events.
    public var delegate: BLELocationManagerDelegate?
    /// Boolean value specifying whether max step algorithm should be enabled. Default value is `false`.
    public var maxStepEnabled = false
    /// Boolean value specifying whether distance should be obtained as `CLBeacon`'s accuracy or calculated. Default value is `true`.
    public var useCLBeaconAccuracy = true
    /// Average receiver's height in centimeters. Default value is `120`.
    public var receiverHeight = 120.0
    /// If `maxStepEnabled` is `true`, this is the value of maximum step a reciver is able to make in centimeters. Default value is `200`.
    public var maxStep = 200.0
    /// A path-loss exponent that varies in value depending on the environment. Default value is `2.0`.
    public var n = 2.0
    
    /// Current floor ID estimated by BLE localization.
    private(set) public var currentFloor: Int?
    
    private var beaconManager: BeaconManager
    private var authorizationStatus: INAuthorizationStatus?
    private var lastPosition: INLocation?
    private var lastPositions = [INLocation]()
    private var sameFloorCounter = 0
    
    /// Initializes a new `BLELocationManager` with the provided parameters.
    ///
    /// - Parameters:
    ///   - beaconUUID: The unique ID of the beacons being targeted.
    ///   - configurations: Array of `INBeaconConfiguration`, specifying beacons to target. Only iBeacons specified in `configurations` will be considered.
    ///   - delegate: The delegate object to receive update events.
    public init(beaconUUID: UUID, configurations: [INBeaconConfiguration], delegate: BLELocationManagerDelegate? = nil) {
        beaconManager = BeaconManager(configurations: configurations, beaconUUID: beaconUUID)
        self.delegate = delegate
        super.init()
        beaconManager.delegate = self
    }
    
    /// Requests permission to use location services while the app is in the foreground.
    public func requestWhenInUseAuthorization() {
        beaconManager.requestWhenInUseAuthorization()
    }
    
    /// Starts the generation of updates that report the user’s current location.
    public func startUpdatingLocation() {
        beaconManager.startScanning()
    }
    
    /// Stops the generation of location updates.
    public func stopUpdatingLocation() {
        beaconManager.stopScanning()
    }
    
    private func getCurrentLocation(withBeacons beacons: [INBeacon]) -> INLocation? {
        
        guard beacons.count != 0 else {
            return nil
        }
        
        guard beacons.count > 1 else {
            return beacons[0].location
        }
        
        var pairs = [(INLocation,INLocation)]()
        
        for (index, beacon) in beacons[0...beacons.count-2].enumerated() {
            let otherBeacons = beacons[index+1...beacons.count-1]
            
            for otherBeacon in otherBeacons {
                if let (location1,location2) = getPairOfLocations(between: beacon, andBeacon: otherBeacon) {
                    pairs.append((location1,location2))
                }
            }
        }
        
        let firsts = pairs.map { (point1,point2) in
            return point1
        }
        
        let seconds = pairs.map { (point1,point2) in
            return point2
        }
        
        var firstsDistanceSum = 0.0
        for location in firsts {
            for otherLocation in firsts {
                firstsDistanceSum += getDistance(between: location, and: otherLocation)
            }
        }
        
        var secondsDistanceSum = 0.0
        for location in seconds {
            for otherLocation in seconds {
                secondsDistanceSum += getDistance(between: location, and: otherLocation)
            }
        }
        
        let bestLocations = firstsDistanceSum > secondsDistanceSum ? seconds : firsts
        let x = bestLocations.map({ $0.x }).reduce(0, +) / Double(bestLocations.count)
        let y = bestLocations.map({ $0.y }).reduce(0, +) / Double(bestLocations.count)
        let location = INLocation(x: x, y: y)
        
        return location
    }
    
    private func getPairOfLocations(between beacon1: INBeacon, andBeacon beacon2: INBeacon) -> (INLocation,INLocation)? {
        
        if beacon1.location == beacon2.location {
            return (beacon1.location, beacon1.location)
        }
        
        let distanceBetweenBeacons = getDistance(between: beacon1.location, and: beacon2.location)
        let distanceFromBeacon1 = distanceOnPlane(fromBeacon: beacon1)
        let distanceFromBeacon2 = distanceOnPlane(fromBeacon: beacon2)
        let delta = getDelta(d1: distanceFromBeacon1, d2: distanceFromBeacon2, distance: distanceBetweenBeacons)
        
        if distanceFromBeacon1 + distanceFromBeacon2 > distanceBetweenBeacons && distanceBetweenBeacons > fabs(distanceFromBeacon1 - distanceFromBeacon2) && delta > 0 {
            var x = beacon2.location.x - beacon1.location.x
            var y = beacon2.location.y - beacon1.location.y
            
            x *= (distanceFromBeacon1*distanceFromBeacon1 - distanceFromBeacon2*distanceFromBeacon2)
            y *= (distanceFromBeacon1*distanceFromBeacon1 - distanceFromBeacon2*distanceFromBeacon2)
            x /= (2 * distanceBetweenBeacons*distanceBetweenBeacons)
            y /= (2 * distanceBetweenBeacons*distanceBetweenBeacons)
            
            x += (beacon1.location.x + beacon2.location.x) / 2
            y += (beacon1.location.y + beacon2.location.y) / 2
            
            let dx = 2*Double(beacon1.location.y - beacon2.location.y)*delta/(distanceBetweenBeacons*distanceBetweenBeacons)
            let dy = 2*Double(beacon1.location.x - beacon2.location.x)*delta/(distanceBetweenBeacons*distanceBetweenBeacons)
            
            let location1 = INLocation(x: x + dx, y: y - dy)
            let location2 = INLocation(x: x - dx, y: y + dy)
            return (location1,location2)
        } else {
            let location = getLocationBetweenCircles(for: beacon1, and: beacon2)
            return (location,location)
        }
    }
    
    private func getLocationBetweenCircles(for beacon1: INBeacon, and beacon2: INBeacon) -> INLocation {
        let distanceFromBeacon1 = distanceOnPlane(fromBeacon: beacon1)
        let distanceFromBeacon2 = distanceOnPlane(fromBeacon: beacon2)
        
        let x, y: Double
        let dx = fabs(beacon1.location.x - beacon2.location.x)
        let dy = fabs(beacon1.location.y - beacon2.location.y)
        
        if beacon1.location.x < beacon2.location.x {
            x = beacon1.location.x + distanceFromBeacon1*dx / (distanceFromBeacon1 + distanceFromBeacon2)
        } else {
            x = beacon2.location.x + distanceFromBeacon2*dx / (distanceFromBeacon1 + distanceFromBeacon2)
        }
        
        if beacon1.location.y < beacon2.location.y {
            y = beacon1.location.y + distanceFromBeacon1*dy / (distanceFromBeacon1 + distanceFromBeacon2)
        } else {
            y = beacon2.location.y + distanceFromBeacon2*dy / (distanceFromBeacon1 + distanceFromBeacon2)
        }
        
        return INLocation(x: x, y: y)
    }
    
    private func distance(fromBeacon beacon: INBeacon) -> Double {
        if useCLBeaconAccuracy {
            return beacon.beacon.accuracy * 100
        }
        
        let rssi = Double(beacon.beacon.rssi)
        let oneMeterRSSI = Double(beacon.configuration.txPower)
        let distance = pow(10.0, (oneMeterRSSI - rssi) / (10.0 * n) ) * 100
        return distance
    }
    
    private func distanceOnPlane(fromBeacon beacon: INBeacon) -> Double {
        let distanceFromBeacon = distance(fromBeacon: beacon)
        let distanceOnPlaneFromBeacon = distanceOnPlane(fromRealDistance: distanceFromBeacon, fromBeaconOnHeight: beacon.configuration.z)
        return distanceOnPlaneFromBeacon
    }
    
    private func getDistance(between location1: INLocation, and location2: INLocation) -> Double {
        let dx = location1.x - location2.x
        let dy = location1.y - location2.y
        return sqrt(dx*dx + dy*dy)
    }
    
    private func getDelta(d1: Double, d2: Double, distance: Double) -> Double {
        let sqrStatement = (distance + d1 + d2) * (distance + d1 - d2) * (distance - d1 + d2) * (-distance + d1 + d2)
        if sqrStatement < 0 {
            return -1
        }
        return sqrt(sqrStatement) / 4
    }
    
    private func distanceOnPlane(fromRealDistance realDistance: Double, fromBeaconOnHeight height: Double) -> Double {
        let planeDistance = sqrt(fabs(pow(realDistance, 2) - pow(height - receiverHeight, 2)))
        return planeDistance
    }
    
    private func updateCurrentFloor(withBeacons beacons: [INBeacon]) {
        let currentFloor = getCurrentFloor(withBeacons: beacons)
        sameFloorCounter = self.currentFloor == currentFloor ? sameFloorCounter + 1 : 0
        self.currentFloor = currentFloor
    }
    
    private func getCurrentFloor(withBeacons beacons: [INBeacon]) -> Int? {
        let currentFloor = beacons.min(by: { $0.beacon.accuracy < $1.beacon.accuracy })?.configuration.floorID
        return currentFloor
    }
}

extension BLELocationManager {
    
    func getPositionMaxStep(withBeacons beacons: [INBeacon]) -> INLocation? {
        let position = getCurrentLocation(withBeacons: beacons)
        
        guard lastPosition != nil else {
            if let position = position {
                lastPositions.append(position)
            }
            
            if lastPositions.count == 5 {
                let x = lastPositions.map({ $0.x }).reduce(0, +) / Double(lastPositions.count)
                let y = lastPositions.map({ $0.y }).reduce(0, +) / Double(lastPositions.count)
                let newPosition = INLocation(x: x, y: y)
                lastPositions.removeAll()
                return newPosition
            }
            
            return nil
        }
        
        let newPosition: INLocation?
        if let last = lastPosition, let position = position, getDistance(between: position, and: last) > maxStep {
            newPosition = getPoint(nearLastPosition: last, inDirectionOfPoint: position)
        } else {
            newPosition = position
        }
        
        return newPosition
    }
    
    private func getPoint(nearLastPosition position: INLocation, inDirectionOfPoint point: INLocation) -> INLocation {
        let d = getDistance(between: position, and: point)
        let dx = Double(point.x - position.x)
        let dy = Double(point.y - position.y)
        
        let sin = dy/d
        let cos = dx/d
        
        let x = Double(position.x) + cos*maxStep
        let y = Double(position.y) + sin*maxStep
        
        return INLocation(x: x, y: y)
    }
}

extension BLELocationManager: BeaconManagerDelegate {
    
    func errorOccuredWhileStarting(_ localizationError: LocalizationError) {
        delegate?.bleLocationManager(self, didFailWithLocalizationError: localizationError)
    }
    
    func errorOccuredWhileGettingNewData(_ error: Error) {
        delegate?.bleLocationManager(self, didFailWithError: error)
    }
    
    func didRange(beacons: [INBeacon]) {
        guard beacons.count > 0 else {
            lastPosition == nil ? delegate?.bleLocationManagerNoBeaconsDetected(self) : delegate?.bleLocationManagerLeftRegion(self, withLatestKnownLocation: lastPosition!)
            lastPosition = nil
            return
        }
        
        delegate?.bleLocationManager(self, didRangeBeacons: beacons)
        lastPosition = maxStepEnabled ? getPositionMaxStep(withBeacons: beacons) : getCurrentLocation(withBeacons: beacons)
        
        if let location = lastPosition {
            NotificationCenter.default.post(name: .didUpdateLocation, object: self, userInfo: ["location": location])
            delegate?.bleLocationManager(self, didUpdateLocation: location)
            updateCurrentFloor(withBeacons: beacons)
            if let currentFloor = currentFloor, sameFloorCounter == NumberOfFloorMeasurements {
                NotificationCenter.default.post(name: .didChangeFloor, object: self, userInfo: ["floorID": currentFloor])
                delegate?.bleLocationManager(self, didChangeFloor: currentFloor)
            }
        } else if !(maxStepEnabled && lastPositions.count > 0) {
            delegate?.bleLocationManagerNoBeaconsDetected(self)
        }
    }
    
    func didDetectNearby(beacons: [CLBeacon]) {
        delegate?.bleLocationManager(self, didDetectNearbyBeacons: beacons)
    }
    
    func didChange(authorization status: CLAuthorizationStatus) {
        delegate?.bleLocationManager(self, didChangeAuthorization: status)
    }
    
    func didUpdate(bluetoothState state: INBluetoothState) {
        delegate?.bleLocationManager(self, didUpdateBluetoothState: state)
    }
}
