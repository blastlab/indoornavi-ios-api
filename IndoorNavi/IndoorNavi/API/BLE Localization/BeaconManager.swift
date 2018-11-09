//
//  BeaconManager.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 28.08.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import CoreLocation

let BeaconIdentifier = "INBeacon"

protocol BeaconManagerDelegate {
    
    func didRange(beacons: [INBeacon])
    
    func didChange(authorization status: CLAuthorizationStatus)
    
    func errorOccured(_ error: Error)
}

class BeaconManager: NSObject {
    
    var configurations = [INBeaconConfiguration]()
    let beaconUUID: UUID
    var delegate: BeaconManagerDelegate?
    
    init(configurations: [INBeaconConfiguration], beaconUUID: UUID, delegate: BeaconManagerDelegate? = nil) {
        self.configurations = configurations
        self.beaconUUID = beaconUUID
        self.delegate = delegate
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: BeaconIdentifier)
        super.init()
        locationManager.delegate = self
    }
    
    private var locationManager = CLLocationManager()
    private var beaconRegion: CLBeaconRegion
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startScanning() {
        locationManager.startMonitoring(for: beaconRegion)
    }
    
    func stopScanning() {
        locationManager.stopRangingBeacons(in: beaconRegion)
        locationManager.stopMonitoring(for: beaconRegion)
    }
    
    private func inBeacons(fromCLBeacons beacons: [CLBeacon]) -> [INBeacon] {
        let inBeacons: [INBeacon] = beacons.compactMap { beacon in
            
            guard beacon.proximity != .unknown else {
                return nil
            }
            
            let configuration = configurations.filter { $0.major == beacon.major.intValue && $0.minor == beacon.minor.intValue }
            
            if configuration.count > 0 {
                return INBeacon(beacon: beacon, configuration: configuration[0])
            }
            
            return nil
        }
        
        if inBeacons.count > 3 {
            let threeNearestBeacons = Array(inBeacons[0...2])
            return threeNearestBeacons
        }
        
        return inBeacons
    }
}

extension BeaconManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.didChange(authorization: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == beaconRegion.identifier {
            manager.startRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == beaconRegion.identifier {
            manager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let newBeacons = inBeacons(fromCLBeacons: beacons)
        delegate?.didRange(beacons: newBeacons)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.errorOccured(error)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        delegate?.errorOccured(error)
    }
}
