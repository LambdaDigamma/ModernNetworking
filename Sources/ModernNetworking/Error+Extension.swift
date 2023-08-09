//
//  Error+Extension.swift
//  
//
//  Created by Lennart Fischer on 29.04.23.
//

import Foundation
import Combine

public extension Error {
    
    var debugDescription: String {
        return String(describing: self)
    }
    
}

public extension Subscribers.Completion<Error> {
    
    var debugDescription: String? {
        switch self {
            case .finished:
                return nil
            case .failure(let failure):
                return failure.debugDescription
        }
    }
    
}
