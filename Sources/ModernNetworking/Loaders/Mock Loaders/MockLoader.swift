//
//  MockLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


open class MockLoader: HTTPLoader {

    open override func load(_ request: HTTPRequest) async -> HTTPResult {
        .failure(HTTPError(.cannotConnect, request))
    }
    
}
