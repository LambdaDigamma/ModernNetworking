//
//  MockLoader.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation

@available(OSX 10.15, *)
@available(iOS 13.0, *)
public class MockLoader: HTTPLoader {
    
    override public func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: HTTPStatus(rawValue: 200).rawValue, httpVersion: "1.1", headerFields: nil)!
        let response = HTTPResponse(request: request, response: urlResponse, body: nil)
        completion(.success(response))
        
    }
    
}
