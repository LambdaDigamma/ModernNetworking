//
//  CacheMode.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import Foundation

public enum CacheMode {
    
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
