//
//  DeviceDataManagerTests.swift
//  IndoorNaviTests
//
//  Created by Michał Pastwa on 11.09.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import XCTest
@testable import IndoorNavi

class DeviceDataManagerTests: XCTestCase {
    
    let positions = [CGPoint(x: 100, y: 100), CGPoint(x: 110, y: 90), CGPoint(x: 120, y: 90)]
    
    var deviceDataManager: DeviceDataManager!
    
    override func setUp() {
        deviceDataManager = DeviceDataManager(targetHost: Constants.BackendTargetHost, apiKey: Constants.ApiKey)
    }
    
    override func tearDown() {
        deviceDataManager = nil
    }
    
    func testRegisterDevice() {
        let registerDevicePromise = expectation(description: "Device registered successfully.")
        
        deviceDataManager.registerDevice(withUserData: "User data") { id, error in
            guard id != nil else {
                XCTFail("Device ID is nil.")
                return
            }
            
            guard error == nil else {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            registerDevicePromise.fulfill()
        }
        
        waitForExpectations(timeout: 15)
    }
    
    func testSendCoordinates() {
        let registerDevicePromise = expectation(description: "Device registered successfully.")
        let sendCoordinatesPromise = expectation(description: "Data sent successfully.")
        
        deviceDataManager.registerDevice(withUserData: "User data") { id, error in
            guard let id = id else {
                XCTFail("Device ID is nil.")
                return
            }
            
            guard error == nil else {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            registerDevicePromise.fulfill()
            
            self.deviceDataManager.send(self.positions, date: Date(), floorID: Constants.FloorID, deviceID: id) { error in
                guard error == nil else {
                    XCTFail("Error: \(error!.localizedDescription)")
                    return
                }
                
                sendCoordinatesPromise.fulfill()
            }
        }
        
        
        
        waitForExpectations(timeout: 30)
    }
}
