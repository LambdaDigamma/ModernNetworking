//
//  PrintLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import OSLog


public class PrintLoader: HTTPLoader {
    
    private let logger: Logger
    
#if DEBUG
    private let enabled: Bool = false
#else
    private let enabled: Bool = false
#endif
    
    public init(logger: Logger = Logging.logger(for: "PrintLoader")) {
        self.logger = logger
        super.init()
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        if self.enabled {
            self.logger.info("Loading \(request.url?.absoluteString ?? "unknown")")
        }
        
        let result = await super.load(request)
        
        if self.enabled {
            
            self.logger.info("Loaded: \(request.url?.absoluteString ?? "unknown")")
            
            switch result {
                case .success(let response):
                    self.logger.info("Received result: success")
                    guard let data = response.body else { break }
                    self.logger.info("\(String(decoding: data, as: UTF8.self))")
                case .failure(let error):
                    self.logger.info("Received result: failure")
                    self.logger.error("Failed with error: \(error.localizedDescription)")
                    if let underlyingError = error.underlyingError {
                        self.logger.error("\(underlyingError.localizedDescription)")
                    }
            }
            
        }
            
        return result
    }
    
}
