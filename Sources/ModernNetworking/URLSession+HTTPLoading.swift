//
//  URLSession+HTTPLoading.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation

//extension URLSession: HTTPLoading {
//
//    public var nextLoader: HTTPLoader? {
//        get {
//            return nil
//        }
//        set {
//            self.nextLoader = newValue
//        }
//    }
//
//
//    public func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
//
//        guard let url = request.url else {
//
//            let error = HTTPError(code: .invalidRequest, request: request, response: nil, underlyingError: nil)
//
//            completion(.failure(error))
//
//            return
//
//        }
//
//        // construct the URLRequest
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = request.method.rawValue
//
//        // copy over any custom HTTP headers
//        for (header, value) in request.headers {
//            urlRequest.addValue(value, forHTTPHeaderField: header)
//        }
//
//        if request.body.isEmpty == false {
//            // if our body defines additional headers, add them
//            for (header, value) in request.body.additionalHeaders {
//                urlRequest.addValue(value, forHTTPHeaderField: header)
//            }
//
//            // attempt to retrieve the body data
//            do {
//                urlRequest.httpBody = try request.body.encode()
//            } catch {
//
//                // something went wrong creating the body; stop and report back
//                completion(.failure(HTTPError(code: .invalidRequest, request: request, response: nil, underlyingError: error)))
//                return
//            }
//        }
//
//        let dataTask = self.dataTask(with: urlRequest) { (data, response, error) in
//
//            if let urlResponse = response as? HTTPURLResponse {
//
//                let response = HTTPResponse(request: request, response: urlResponse, body: data)
//
//                if let error = error {
//                    completion(.failure(HTTPError(code: .invalidResponse, request: request, response: response, underlyingError: error)))
//                } else {
//                    completion(.success(response))
//                }
//
//            }
//
//            completion(.failure(HTTPError(code: .unknown, request: request, response: nil, underlyingError: error)))
//
//        }
//
//        dataTask.resume()
//
//    }
//
//}
