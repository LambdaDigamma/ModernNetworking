//
//  HTTPLoading.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public protocol HTTPLoading {
    
    var nextLoader: HTTPLoader? { get set }
    
    func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void)
    
    func load<T: Model>(request: HTTPRequest) -> AnyPublisher<T, HTTPError>
    
}

