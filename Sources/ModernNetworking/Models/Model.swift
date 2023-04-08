//
//  Model.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public protocol Model: Codable {
    
    static var decoder: JSONDecoder { get }
    
    static var encoder: JSONEncoder { get }
    
}

public extension Model {
    
    static var decoder: JSONDecoder {
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
        
    }
    
    static var encoder: JSONEncoder {
        
        let encoder = JSONEncoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        return encoder
        
    }
    
}

extension Array: Model where Element: Model {
    
    public static var decoder: JSONDecoder {
        return Element.decoder
    }
    
    public static var encoder: JSONEncoder {
        return Element.encoder
    }
    
}

/// A type that represents no model value is present
public struct Empty: Model {
}

extension Optional<Int64> {
    
    public func toInt() -> Int? {
        if let self = self {
            return Int(truncatingIfNeeded: self)
        } else {
            return nil
        }
    }
    
}

extension Optional<Int> {
    
    public func toInt64() -> Int64? {
        if let self = self {
            return Int64(truncatingIfNeeded: self)
        } else {
            return nil
        }
    }
    
}

extension Int {
    
    public func toInt64() -> Int64 {
        
        return Int64(truncatingIfNeeded: self)
        
    }
    
}
