//
//  PrintLoader.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class PrintLoader: HTTPLoader {
    
    public override func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        print("Loading \(request)")
        super.load(request: request, completion: { result in
            print("Got result: \(result)")
            completion(result)
        })
    }
    
    public override func load<T>(request: HTTPRequest) -> AnyPublisher<T, HTTPError> where T : Model {
        return super.load(request: request) // TODO: Check whether this is evil!
    }
    
}
