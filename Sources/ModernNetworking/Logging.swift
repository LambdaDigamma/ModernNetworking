//
//  Logging.swift
//  
//
//  Created by Lennart Fischer on 01.11.21.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
public class Logging {
    
    @available(iOS 14.0, *)
    public static let logger: Logger = Logger(subsystem: "com.lambdadigamma.modernnetworking", category: "ModernNetworking")
    
}
