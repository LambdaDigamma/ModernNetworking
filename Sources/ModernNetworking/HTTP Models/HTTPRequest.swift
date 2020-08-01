//
//  HTTPRequest.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation

public struct HTTPRequest {
    
    public var id = UUID()
    
    private var urlComponents = URLComponents()
    public var method: HTTPMethod = .get
    public var headers: [String: String] = [:]
    public var body: HTTPBody = EmptyBody()
    
    public init() {
        
    }
    
    private var options = [ObjectIdentifier: Any]()
    
    public subscript<O: HTTPRequestOption>(option type: O.Type) -> O.Value {
        get {
            // create the unique identifier for this type as our lookup key
            let id = ObjectIdentifier(type)
            
            // pull out any specified value from the options dictionary, if it's the right type
            // if it's missing or the wrong type, return the defaultOptionValue
            guard let value = options[id] as? O.Value else { return type.defaultOptionValue }
            
            // return the value from the options dictionary
            return value
        }
        set {
            let id = ObjectIdentifier(type)
            // save the specified value into the options dictionary
            options[id] = newValue
        }
    }
    
}

public extension HTTPRequest {
    
    var scheme: String { urlComponents.scheme ?? "https" }
    
    var host: String? {
        get { urlComponents.host }
        set { urlComponents.host = newValue }
    }
    
    var path: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }
    
    var url: URL? {
        
        var urlString = scheme.appending("://")
            
        if let host = host {
            urlString.append(host)
        }
        
        urlString.append(path)
        
        return URL(string: urlString)
        
    }
    
}

extension HTTPRequest {
    
    public var serverEnvironment: ServerEnvironment? {
        get { self[option: ServerEnvironment.self] }
        set { self[option: ServerEnvironment.self] = newValue }
    }
    
}
