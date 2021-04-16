//
//  File.swift
//  
//
//  Created by Lennart Fischer on 13.01.21.
//

import Foundation


public struct Resource<T: Model>: Codable {
    
    public let data: T
    
}

extension Resource: Model {
    public static var decoder: JSONDecoder { T.decoder }
    public static var encoder: JSONEncoder { T.encoder }
}
