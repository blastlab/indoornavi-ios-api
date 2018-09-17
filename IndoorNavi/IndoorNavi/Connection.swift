//
//  Connection.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 05.09.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/// A Connection class is responsible for communication with backend server.
public class Connection {
    
    fileprivate struct WebRoutes {
        static let Auth = "/auth"
        static let RestPhones = "/rest/v1/phones"
    }
    
    private var targetHost: String
    private var apiKey: String
    
    /// Initializes a new `Connection` object with the provided parameters to communicate with backend server.
    ///
    /// - Parameters:
    ///   - targetHost: Address to the backend server.
    ///   - apiKey: The API key created on the backend server.
    public init(targetHost: String, apiKey: String) {
        self.targetHost = targetHost + WebRoutes.RestPhones
        self.apiKey = apiKey
    }
    
    /// Registers device on the backend server with a `userData`. If successful, ID of the device is returned in response.
    ///
    ///   - Parameter userData: User data describing the device.
    ///   - Parameter completionHandler: The completion handler to call when the load request is complete. This completion handler takes the following parameters:
    ///   - Parameter id: ID of the device in database.
    ///   - Parameter error: An error object that in dicates why the request failed, or nil if the request was successful.
    public func registerDevice(withUserData userData: String, completionHandler: @escaping ((_ id: Int?, _ error: Error?) -> Void)) {
        let request = getRegisterDeviceRequest(withUserData: userData)
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
    
    private func getRegisterDeviceRequest(withUserData userData: String) -> URLRequest {
        let url = URL(string: targetHost + WebRoutes.Auth)!
        let parameterDictionary = ["userData" : userData]
        let httpBody = try! JSONSerialization.data(withJSONObject: parameterDictionary, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Accept")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + apiKey, forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody
        
        return request
    }
}
