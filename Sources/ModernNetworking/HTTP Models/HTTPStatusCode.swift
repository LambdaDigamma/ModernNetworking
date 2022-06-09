//
//  HTTPStatusCode.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public struct HTTPStatusCode: Hashable, Equatable {

    /// HTTP Ok (`200`)
    public static let ok = HTTPStatusCode(value: 200)
    
    /// HTTP Created (`201`)
    public static let created = HTTPStatusCode(value: 201)
    
    /// HTTP No Content (`204`)
    public static let noContent = HTTPStatusCode(value: 204)
    
    /// HTTP Reset Content (`205`)
    public static let resetContent = HTTPStatusCode(value: 205)
    
    /// HTTP Moved Permanently (`301`)
    public static let movedPermanently = HTTPStatusCode(value: 301)
    
    /// HTTP Bad Request (`400`)
    public static let badRequest = HTTPStatusCode(value: 400)
    
    /// HTTP Unauthorized (`401`)
    public static let unauthorized = HTTPStatusCode(value: 401)
    
    /// HTTP Forbidden (`403`)
    public static let forbidden = HTTPStatusCode(value: 403)
    
    /// HTTP Not Found (`404`)
    public static let notFound = HTTPStatusCode(value: 404)
    
    /// HTTP Conflict (`409`)
    public static let conflict = HTTPStatusCode(value: 409)
    
    /// HTTP Unprocessable Entity (`422`)
    public static let unprocessableEntity = HTTPStatusCode(value: 422)
    
    /// HTTP Internal Server Error (`500`)
    public static let internalServerError = HTTPStatusCode(value: 500)
    
    public let value: Int
    
    public init(value: Int) {
        self.value = value
    }

}

// MARK: - CustomStringConvertible API

extension HTTPStatusCode: CustomStringConvertible {

    public var description: String {
        "\(value)"
    }

}
