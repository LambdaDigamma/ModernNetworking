//
//  HTTPRequest.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public struct HTTPRequest: Equatable {
    
    public var method: HTTPMethod = .get
    public var headers: [String: String] = [:]
    public var body: HTTPBody = EmptyBody()

    public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    
    public init() {
        urlComponents.scheme = "https"
    }
    
    public init(
        method: HTTPMethod = .get,
        path: String,
        body: HTTPBody = EmptyBody(),
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) {
        urlComponents.scheme = "https"
        self.method = method
        self.path = path
        self.body = body
        self.headers = headers
        self.queryItems = queryItems
        self.cachePolicy = cachePolicy
    }

    private var urlComponents = URLComponents()
    private var options = [ObjectIdentifier: Any]()

    /// Attention: use this only for debugging and testing.
    /// The request body is not being compared.
    public static func == (lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
        return lhs.method == rhs.method
            && lhs.headers == rhs.headers
            && lhs.urlComponents == rhs.urlComponents
    }
    
}

// MARK: - Convenience API

extension HTTPRequest {

    public var url: URL? {
        urlComponents.url
    }

    public var scheme: String {
        get {
            urlComponents.scheme ?? "https"
        }
        set {
            urlComponents.scheme = newValue
        }
        
    }

    public var host: String? {
        get { urlComponents.host }
        set { urlComponents.host = newValue }
    }

    public var path: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }

    public var serverEnvironment: ServerEnvironment? {
        get { self[option: ServerEnvironment.self] }
        set { self[option: ServerEnvironment.self] = newValue }
    }
    
    public var queryItems: [URLQueryItem] {
        get { urlComponents.queryItems ?? [] }
        set { urlComponents.queryItems = newValue }
    }

    public subscript <O: HTTPRequestOption> (option type: O.Type) -> O.Value {
        get {
            let id = ObjectIdentifier(type)
            guard let value = options[id] as? O.Value else {
                return type.defaultOptionValue
            }
            return value
        }
        set {
            let id = ObjectIdentifier(type)
            options[id] = newValue
        }
    }

}
