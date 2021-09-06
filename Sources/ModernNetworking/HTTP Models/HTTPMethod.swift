//
//  HTTPMethod.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


/// The HTTP spec does not define the allowed HTTP methods.
/// Technically this could be any verb.
/// The most common methods are defined as static members.
public struct HTTPMethod: Hashable, Equatable {

    /// Represents a `GET` HTTP request.
    public static let get = HTTPMethod("GET")
    
    /// Represents a `POST` HTTP request.
    public static let post = HTTPMethod("POST")
    
    /// Represents a `PUT` HTTP request.
    public static let put = HTTPMethod("PUT")
    
    /// Represents a `PATCH` HTTP request.
    public static let patch = HTTPMethod("PATCH")
    
    /// Represents a `DELETE` HTTP request.
    public static let delete = HTTPMethod("DELETE")

    public init(_ name: String) {
        self.name = name
    }

    public let name: String

}

// MARK: - CustomStringConvertible API

extension HTTPMethod: CustomStringConvertible {

    public var description: String {
        name
    }

}
