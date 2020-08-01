//
//  HTTPError.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation

public typealias HTTPResult = Result<HTTPResponse, HTTPError>

public struct HTTPError: Error {
    
    /// The high-level classification of this error
    public let code: Code
    
    /// The HTTPRequest that resulted in this error
    public let request: HTTPRequest
    
    /// Any HTTPResponse (partial or otherwise) that we might have
    public let response: HTTPResponse?
    
    /// If we have more information about the error that caused this, stash it here
    public let underlyingError: Error?
    
    public enum Code {
        case invalidRequest     // the HTTPRequest could not be turned into a URLRequest
        case cannotConnect      // some sort of connectivity problem
        case cancelled          // the user cancelled the request
        case insecureConnection // couldn't establish a secure connection to the server
        case invalidResponse    // the system did not receive a valid HTTP response
        case decodingError
        case resourceNotFound
        case noData
        case resetInProgress
        case unknown            // we have no idea what the problem is
    }
    
}

extension HTTPResult {
    
    public var request: HTTPRequest {
        switch self {
            case .success(let response): return response.request
            case .failure(let error): return error.request
        }
    }
    
    public var response: HTTPResponse? {
        switch self {
            case .success(let response): return response
            case .failure(let error): return error.response
        }
    }
    
}
