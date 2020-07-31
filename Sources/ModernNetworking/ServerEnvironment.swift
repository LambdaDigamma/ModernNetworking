//
//  ServerEnvironment.swift
//  24doors
//
//  Created by Lennart Fischer on 18.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation


public struct ServerEnvironment: HTTPRequestOption {
    
    public static let defaultOptionValue: ServerEnvironment? = nil
    
    public var host: String
    public var pathPrefix: String
    public var headers: [String: String]
    public var query: [URLQueryItem]
    
    public init(host: String, pathPrefix: String = "/", headers: [String: String] = [:], query: [URLQueryItem] = []) {
        // make sure the pathPrefix starts with a /
        let prefix = pathPrefix.hasPrefix("/") ? "" : "/"
        
        self.host = host
        self.pathPrefix = prefix + pathPrefix
        self.headers = headers
        self.query = query
    }
    
}

extension ServerEnvironment {
    
    public static let development = ServerEnvironment(host: "development.24doors.app", pathPrefix: "/api")
    public static let staging = ServerEnvironment(host: "staging.24doors.app", pathPrefix: "/api")
    public static let production = ServerEnvironment(host: "24doors.app", pathPrefix: "/api")
    
}
