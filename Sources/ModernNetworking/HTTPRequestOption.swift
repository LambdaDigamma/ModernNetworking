//
//  HTTPRequestOption.swift
//  24doors
//
//  Created by Lennart Fischer on 18.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation


public protocol HTTPRequestOption {
    
    associatedtype Value
    
    /// The value to use if a request does not provide a customized value
    static var defaultOptionValue: Value { get }
    
}
