//
//  CacheMode.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import Foundation

nonisolated public enum CacheMode: Sendable {
    
    case cached
    case revalidate
    case reload
    
    public var policy: URLRequest.CachePolicy {
        switch self {
            case .cached:
                return .useProtocolCachePolicy
            case .revalidate:
                return .reloadRevalidatingCacheData
            case .reload:
                return .reloadIgnoringLocalAndRemoteCacheData
        }
    }
    
}
