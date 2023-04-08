//
//  URLSessionLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public final class URLSessionLoader: HTTPLoader {

    public init(_ session: URLSession = .shared) {
        self.session = session
    }

    public override func load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {
        _load(request, completion: completion)
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        await _load(request)
    }

    private let session: URLSession

}

// MARK: - Private API

extension URLSessionLoader {

    private func _load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {

        guard let url = request.url else {
            let error = HTTPError(.invalidRequest(.invalidURL), request)
            completion(.failure(error))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.name
        urlRequest.cachePolicy = request.cachePolicy
        
        // add custom HTTP headers from the request
        for (header, value) in request.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }

        if request.body.isEmpty == false {

            // add custom HTTP headers from the body
            for (header, value) in request.body.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }

            do { urlRequest.httpBody = try request.body.encode() } catch {
                let error = HTTPError(.invalidRequest(.invalidBody), request)
                completion(.failure(error))
                return
            }

        }

        if let cachedResponse = session.configuration.urlCache?.cachedResponse(for: urlRequest) {
            print("Cached response")
            print(cachedResponse.response)
            print(String(data: cachedResponse.data, encoding: .utf8)!)
        }
        
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            let result = self.makeHTTPResult(request, data, response, error)
            completion(result)
        }

        dataTask.resume()

    }

    private func _load(_ request: HTTPRequest) async -> HTTPResult {
        
        guard let url = request.url else {
            let error = HTTPError(.invalidRequest(.invalidURL), request)
            return .failure(error)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.name
        urlRequest.cachePolicy = request.cachePolicy
        
        // add custom HTTP headers from the request
        for (header, value) in request.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }
        
        if request.body.isEmpty == false {
            
            // add custom HTTP headers from the body
            for (header, value) in request.body.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }
            
            do { urlRequest.httpBody = try request.body.encode() } catch {
                let error = HTTPError(.invalidRequest(.invalidBody), request)
                return .failure(error)
            }
            
        }
        
        if let cachedResponse = session.configuration.urlCache?.cachedResponse(for: urlRequest) {
            print("Cached response")
            print(cachedResponse.response)
            print(String(data: cachedResponse.data, encoding: .utf8)!)
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            return self.makeHTTPResult(request, data, response, nil)
            
        } catch {
            return self.makeHTTPResult(request, nil, nil, error)
        }
        
    }
    
    private func makeHTTPResult(
        _ request: HTTPRequest,
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?
    ) -> HTTPResult {

        var httpResponse: HTTPResponse?

        if let response = response as? HTTPURLResponse {
            httpResponse = HTTPResponse(request, response, data)
        }

        // an URL error
        if let error = error as? URLError {
            let code: HTTPError.Code
            switch error.code {

                case .badURL:
                    code = .invalidRequest(.invalidURL)

                // case .unsupportedURL: code = ...
                // case .cannotFindHost: code = ...
                // ...

                default:
                    code = .unknown

            }
            let httpError = HTTPError(code, request, httpResponse, error)
            return .failure(httpError)
        }

        // an error, but not a URL error
        else if let error = error {
            let httpError = HTTPError(.unknown, request, httpResponse, error)
            return .failure(httpError)
        }

        // no error, and an HTTPURLResponse
        else if let response = httpResponse {
            return .success(response)
        }

        // not an error, but also not an HTTPURLResponse
        else {
            let httpError = HTTPError(.invalidResponse, request, nil, error)
            return .failure(httpError)
        }

    }

}
