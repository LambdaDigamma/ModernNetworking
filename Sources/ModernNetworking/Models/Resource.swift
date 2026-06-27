//
//  Resource.swift
//  
//
//  Created by Lennart Fischer on 13.01.21.
//

import Foundation


nonisolated public struct Resource<T: Model>: Codable {
    
    public let data: T
    
    public init(data: T) {
        self.data = data
    }
    
}

nonisolated extension Resource: Model {
    public static var decoder: JSONDecoder { T.decoder }
    public static var encoder: JSONEncoder { T.encoder }
}
