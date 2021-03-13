//
//  UIResource.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

public enum UIResource<T> {
    
    case loading
    case success(T)
    case error(Error)
    
}

extension UIResource {
    
    var loading: Bool {
        
        if case .loading = self {
            return true
        }
        
        return false
        
    }
    
    var error: Error? {
        
        switch self {
            case .error(let error):
                return error
            default:
                return nil
        }
        
    }
    
    var value: T? {
        
        switch self {
            case .success(let value):
                return value
            default:
                return nil
        }
        
    }
    
}

#if canImport(SwiftUI)

import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
public extension UIResource {
    
    /**
     Transform a `Resource<T>` to a `Resource<S>`
     */
    func transform<S>(_ t: @escaping (T) -> S) -> UIResource<S> {
        switch self {
            case .loading:
                return .loading
            case .error(let error):
                return .error(error)
            case .success(let value):
                return .success(t(value))
        }
    }
    
    func isLoading<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Content? {
        
        if loading {
            return content()
        }
        
        return nil
    }
    
    func hasResource<Content: View>(@ViewBuilder content: @escaping (T) -> Content) -> Content? {
        if let value = value {
            return content(value)
        }
        
        return nil
    }
    
    func hasError<Content: View>(@ViewBuilder content: @escaping (Error) -> Content) -> Content? {
        
        if let error = error {
            return content(error)
        }
        
        return nil
    }
}

#endif
