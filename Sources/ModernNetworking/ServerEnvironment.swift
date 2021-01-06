//
//  ServerEnvironment.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

public struct ServerEnvironment: HTTPRequestOption {

    public var scheme: String = "https"
    public var host: String
    public var pathPrefix: String
    public var headers: [String: String]
    public var query: [URLQueryItem]

    public static let defaultOptionValue: ServerEnvironment? = nil

    public init(
        scheme: String = "https",
        host: String,
        pathPrefix: String = "/",
        headers: [String: String] = [:],
        query: [URLQueryItem] = []
    ) {

        // make sure the pathPrefix starts with a /
        let prefix = pathPrefix.hasPrefix("/") ? "" : "/"

        self.scheme = scheme
        self.host = host
        self.pathPrefix = prefix + pathPrefix
        self.headers = headers
        self.query = query

    }

}
