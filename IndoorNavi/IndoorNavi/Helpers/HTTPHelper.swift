//
//  HTTPHelper.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 06/02/2019.
//  Copyright © 2019 BlastLab. All rights reserved.
//

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

class HTTPHelper: NSObject {
    
    static func getRequest(withURL url: URL, apiKey: String, httpMethod: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
//        request.httpMethod = httpMethod.rawValue
        request.setValue("Application/json", forHTTPHeaderField: "Accept")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + apiKey, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    static func getRequest(withURL url: URL, andHTTPBody httpBody: Data, apiKey: String, httpMethod: HTTPMethod) -> URLRequest {
        var request = getRequest(withURL: url, apiKey: apiKey, httpMethod: httpMethod)
        request.httpBody = httpBody
        
        return request
    }
}
