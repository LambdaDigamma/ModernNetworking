//
//  HTTPError.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public struct HTTPError: Error, Equatable {
    
    public let code: Code
    public let request: HTTPRequest
    public let response: HTTPResponse?
    public let underlyingError: Error?

    public init(
        _ code: Code,
        _ request: HTTPRequest,
        _ response: HTTPResponse? = nil,
        _ underlyingError: Error? = nil
    ) {
        self.code = code
        self.request = request
        self.response = response
        self.underlyingError = underlyingError
    }

    public enum Code: Equatable {
        
        /// The HTTPRequest could not be turned into a URLRequest.
        case invalidRequest(InvalidRequest)
        
        /// There was some sort of connectivity problem.
        case cannotConnect
        
        /// The user cancelled the request.
        case cancelled
        
        /// Couldn't establish a secure connection to the server.
        case insecureConnection
        
        /// The system did not receive a valid HTTP response.
        case invalidResponse
        
        /// A decoding error occured.
        case decodingError
        
        /// The loader is currently resetting its state.
        case resetInProgress
        
        /// We basically have no idea what the problem is.
        /// Sorry 'bout that.
        case unknown
    }

    public enum InvalidRequest: Equatable {
        case invalidURL
        case invalidBody
        case unknown
    }

    /// Attention: use this only for debugging and testing.
    /// Only the code, response and underlying errors are being compared.
    public static func == (lhs: HTTPError, rhs: HTTPError) -> Bool {
        return lhs.code == rhs.code
            && lhs.response == rhs.response
            && lhs.underlyingError?.localizedDescription == rhs.underlyingError?.localizedDescription
    }
    
}
