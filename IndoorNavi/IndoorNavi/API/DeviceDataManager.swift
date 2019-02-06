//
//  DeviceDataManager.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 05.09.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// A DeviceDataManager class is responsible for communication with backend server.
public class DeviceDataManager {
    
    private var targetHost: String
    private var apiKey: String
    
    /// Initializes a new `DeviceDataManager` object with the provided parameters to communicate with backend server.
    ///
    /// - Parameters:
    ///   - targetHost: Address to the backend server.
    ///   - apiKey: The API key created on the backend server.
    public init(targetHost: String, apiKey: String) {
        self.targetHost = targetHost + WebRoutes.Rest + WebRoutes.Phones
        self.apiKey = apiKey
    }
    
    /// Registers device on the backend server with a `userData`. If successful, ID of the device is returned in response.
    ///
    ///   - Parameter userData: User data describing the device.
    ///   - Parameter completionHandler: The completion handler to call when the request is complete. This completion handler takes the following parameters:
    ///   - Parameter id: ID of the device in database.
    ///   - Parameter error: An error object that in dicates why the request failed, or nil if the request was successful.
    public func registerDevice(withUserData userData: String, completionHandler: @escaping ((_ id: Int?, _ error: Error?) -> Void)) {
        if let request = getRegisterDeviceRequest(withUserData: userData) {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard let data = data, error == nil else {
                    completionHandler(nil, error)
                    return
                }
                
                if let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let id = jsonDictionary?["id"] as? Int {
                    completionHandler(id, nil)
                }
            }.resume()
        }
    }
    
    /// Sends `coordinates` registered by the device specified with `deviceID` with specific `date`, on map with ID specified by `floorID`.
    ///
    /// - Parameters:
    ///   - coordinates: Array of points representing position of the device.
    ///   - date: Time when position data was gathered.
    ///   - floorID: ID of the current map.
    ///   - deviceID: ID of the device in database, returned after registration.
    ///   - completionHandler: The `Optional` completion handler to call when the request is complete. This completion handler takes the following parameters:
    ///   - error: An error object that in dicates why the request failed, or nil if the request was successful.
    public func send(_ coordinates: [CGPoint], date: Date, floorID: Int, deviceID: Int, completionHandler: ((_ error: Error?) -> Void)? = nil) {
        if let request = getCoordinatesRequest(withCoordinates: coordinates, date: date, floorID: floorID, devieID: deviceID) {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completionHandler?(error)
                    return
                }
                
                completionHandler?(nil)
            }.resume()
        }
    }
    
    private func getRegisterDeviceRequest(withUserData userData: String) -> URLRequest? {
        let url = URL(string: targetHost + WebRoutes.Auth)!
        let parameterDictionary = ["userData" : userData]
        if let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) {
            let request = HTTPHelper.getRequest(withURL: url, andHTTPBody: httpBody, apiKey: apiKey, httpMethod: .post)
            return request
        }
        
        return nil
    }
    
    private func getCoordinatesRequest(withCoordinates coordinates: [CGPoint], date: Date, floorID: Int, devieID: Int) -> URLRequest? {
        let url = URL(string: targetHost + WebRoutes.Coordinates)!
        var coordinatesDictionaryArray = [[String: Any]]()

        for coordinate in coordinates {
            coordinatesDictionaryArray.append(["floorId": String(floorID), "point": PointHelper.pointDictionary(fromPoint: coordinate), "date": dateString(fromDate: date), "phoneId": String(devieID)])
        }
        
        if let httpBody = try? JSONSerialization.data(withJSONObject: coordinatesDictionaryArray, options: []) {
            let request = HTTPHelper.getRequest(withURL: url, andHTTPBody: httpBody, apiKey: apiKey, httpMethod: .post)
            return request
        }
        
        return nil
    }
    
    private func dateString(fromDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}
