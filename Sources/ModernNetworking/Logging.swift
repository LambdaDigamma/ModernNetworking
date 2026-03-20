//
//  Logging.swift
//  
//
//  Created by Lennart Fischer on 01.11.21.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
public enum Logging {
    
    private static let subsystem = "com.lambdadigamma.modernnetworking"
    
    @available(iOS 14.0, *)
    public static let logger: Logger = Logger(
        subsystem: subsystem,
        category: "ModernNetworking"
    )
    
    @available(iOS 14.0, *)
    public static func logger(for category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
    
}
