//
//  FileLoader.swift
//
//
//  Created by Lennart Fischer on 09.12.21.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
public class FileLoader: MockLoader {
    
    private let logger: Logger
    private let statusCode: HTTPStatusCode
    private let resource: String
    private let fileExtension: String
    private let bundle: Bundle
    
    public var fixtureRequest: HTTPRequest?
    
    public init(
        statusCode: HTTPStatusCode = .ok,
        resource: String,
        fileExtension: String,
        bundle: Bundle,
        fixtureRequest: HTTPRequest? = nil
    ) {
        self.logger = Logger(subsystem: "com.lambdadigamma.modernnetworking", category: "FileLoader")
        self.statusCode = statusCode
        self.resource = resource
        self.fileExtension = fileExtension
        self.bundle = bundle
        self.fixtureRequest = fixtureRequest
    }
    
    public override func load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {
        
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: [:]
        )
        
        var data = Data()
        
        if let path = bundle.path(forResource: resource, ofType: fileExtension) {
            
            do {
                
                let content = try String(contentsOfFile: path)
                data = content.data(using: .utf8) ?? Data()
                
            } catch {
                self.logger.error("An error occured: \(error.localizedDescription)")
            }
            
        } else {
            
            self.logger.error("Could not find a file for the provided information.")
        }
        
        let response = HTTPResponse(request, urlResponse!, data)
        
        completion(.success(response))
        
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: [:]
        )
        
        var data = Data()
        
        if let path = bundle.path(forResource: resource, ofType: fileExtension) {
            
            do {
                
                let content = try String(contentsOfFile: path)
                data = content.data(using: .utf8) ?? Data()
                
            } catch {
                self.logger.error("An error occured: \(error.localizedDescription)")
            }
            
        } else {
            
            self.logger.error("Could not find a file for the provided information.")
            
        }
        
        let response = HTTPResponse(request, urlResponse!, data)
        
        return .success(response)
        
    }
    
}
