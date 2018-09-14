//
//  BLELocationManager.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28.08.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import CoreLocation

let ReceiverHeight = 1.2
let n = 2.1

struct INBeacon {
    var beacon: CLBeacon
    var configuration: INBeaconConfiguration
    
    var location: INLocation {
        return INLocation(x: configuration.x, y: configuration.y)
    }
}

public struct INBeaconConfiguration {
    var x: Double
    var y: Double
    var z: Double
    var major: Int
    var minor: Int
    var txPower: Int
    
    public init(x: Double, y: Double, z: Double, txPower: Int, major: Int, minor: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.major = major
        self.minor = minor
        self.txPower = txPower
    }
}

public protocol BLELocationManagerDelegate {
    func bleLocationManager(_ manager: BLELocationManager, didUpdateLocation location: INLocation)
}

public class BLELocationManager: NSObject {
    
    public var delegate: BLELocationManagerDelegate?
    private var beaconManager: BeaconManager
    
    public init(beaconUUID: UUID, configurations: [INBeaconConfiguration], delegate: BLELocationManagerDelegate? = nil) {
        beaconManager = BeaconManager(configurations: configurations, beaconUUID: beaconUUID)
        self.delegate = delegate
        super.init()
        beaconManager.delegate = self
    }
    
    public func startUpdatingLocation() {
        beaconManager.startScanning()
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
        let rssi = Double(beacon.beacon.rssi)
        let oneMeterRSSI = Double(beacon.configuration.txPower)
        let distance = pow(10.0, (oneMeterRSSI - rssi) / (10.0 * n) )
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
        let planeDistance = sqrt(fabs(pow(realDistance, 2) - pow(height - ReceiverHeight, 2)))
        return planeDistance
    }
}

extension BLELocationManager: BeaconManagerDelegate {
    
    func didRange(beacons: [INBeacon]) {
        if let location = getCurrentLocation(withBeacons: beacons) {
            delegate?.bleLocationManager(self, didUpdateLocation: location)
        }
    }
}
