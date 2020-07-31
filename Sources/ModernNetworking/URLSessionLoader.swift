//
//  URLSessionLoader.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class URLSessionLoader: HTTPLoader {
    
    public let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public override func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        
        do {
            
            let urlRequest: URLRequest = try createURLRequest(from: request)
            
            let dataTask = session.dataTask(with: urlRequest) { (responseData, response, error) in
                
                var httpResponse: HTTPResponse?
                if let r = response as? HTTPURLResponse {
                    httpResponse = HTTPResponse(request: request, response: r, body: responseData ?? Data())
                }
                
                if let e = error as? URLError {
                    let code: HTTPError.Code
                    switch e.code {
                        case .badURL: code = .invalidRequest
                        case .unsupportedURL: code = .invalidRequest
                        case .cannotFindHost: code = .cannotConnect
                            
                        default: code = .unknown
                    }
                    completion(.failure(HTTPError(code: code, request: request, response: httpResponse, underlyingError: e)))
                } else if let someError = error {
                    // an error, but not a URL error
                    completion(.failure(HTTPError(code: .unknown, request: request, response: httpResponse, underlyingError: someError)))
                } else if let r = httpResponse {
                    // not an error, and an HTTPURLResponse
                    completion(.success(r))
                } else {
                    // not an error, but also not an HTTPURLResponse
                    completion(.failure(HTTPError(code: .invalidResponse, request: request, response: nil, underlyingError: error)))
                }
                
            }
            
            dataTask.resume()
            
        } catch let error as HTTPError {
            completion(.failure(error))
        } catch {
            completion(.failure(HTTPError(code: .unknown, request: request, response: nil, underlyingError: error)))
        }
        
    }
    
    public override func load<T>(request: HTTPRequest) -> AnyPublisher<T, HTTPError> where T : Model {
        
        do {
            
            let urlRequest = try createURLRequest(from: request)
            
            let test = session
                .dataTaskPublisher(for: urlRequest)
                .tryMap { (data: Data, response: URLResponse) in
                    return try self.processResponse(request: request, data: data, response: response)
                }
                .tryMap { (response: HTTPResponse) in
                    return try self.reduceResponse(request: request, response: response)
                }
                .decode(type: T.self, decoder: T.decoder)
                .mapError { (error: Error) -> HTTPError in
                    
                    if let e = error as? URLError {
                        let code: HTTPError.Code
                        switch e.code {
                            case .badURL: code = .invalidRequest
                            case .unsupportedURL: code = .invalidRequest
                            case .cannotFindHost: code = .cannotConnect
                                
                            default: code = .unknown
                        }
                        
                        return HTTPError(code: code, request: request, response: nil, underlyingError: e)
                        
                    } else {
                        // an error, but not a URL error
                        return HTTPError(code: .unknown, request: request, response: nil, underlyingError: error)
                    }
                    
                }
            
            return test.eraseToAnyPublisher()

        } catch let error as HTTPError {
            return Fail(error: error).eraseToAnyPublisher()
        } catch {
            return Fail(error: HTTPError(code: .unknown, request: request, response: nil, underlyingError: error)).eraseToAnyPublisher()
        }
        
        
        
        
    }
    
    // MARK: - Helpers
    
    private func createURLRequest(from request: HTTPRequest) throws -> URLRequest {
        
        guard let url = request.url else {
            
            let error = HTTPError(code: .invalidRequest, request: request, response: nil, underlyingError: nil)
            
            throw error
            
        }
        
        // construct the URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // copy over any custom HTTP headers
        for (header, value) in request.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }
        
        if request.body.isEmpty == false {
            // if our body defines additional headers, add them
            for (header, value) in request.body.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }
            
            // attempt to retrieve the body data
            do {
                urlRequest.httpBody = try request.body.encode()
            } catch {
                throw HTTPError(code: .invalidRequest, request: request, response: nil, underlyingError: error)
            }
            
        }
        
        return urlRequest
        
    }
    
    private func processResponse(request: HTTPRequest, data: Data, response: URLResponse) throws -> HTTPResponse {
        
        if let r = response as? HTTPURLResponse {
            return HTTPResponse(request: request, response: r, body: data)
        } else {
            throw HTTPError(code: HTTPError.Code.invalidResponse, request: request, response: nil, underlyingError: nil)
        }
        
    }
    
    private func reduceResponse(request: HTTPRequest, response: HTTPResponse) throws -> Data {
        
        if let data = response.body {
            return data
        } else {
            throw HTTPError(code: .noData, request: request, response: response, underlyingError: nil)
        }
        
    }
    
}
