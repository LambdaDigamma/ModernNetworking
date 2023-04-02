//
//  FixtureFileLoader.swift
//  
//
//  Created by Lennart Fischer on 02.04.23.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
public class FixtureFileLoader: MockLoader {
    
    private let logger: Logger
    private let statusCode: HTTPStatusCode
    private let fixtureURL: URL?
    
    public var fixtureRequest: HTTPRequest?
    
    public init(
        statusCode: HTTPStatusCode = .ok,
        fixtureURL: URL? = nil,
        fixtureRequest: HTTPRequest? = nil
    ) {
        self.logger = Logger(subsystem: "com.lambdadigamma.modernnetworking", category: "FixtureFileLoader")
        self.statusCode = statusCode
        self.fixtureURL = fixtureURL
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
        
        if let url = fixtureURL, FileManager.default.fileExists(atPath: url.path) {
            
            do {
                
                data = try Data(contentsOf: url)
                
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
        
        if let url = fixtureURL, FileManager.default.fileExists(atPath: url.path) {
            
            do {
                
                data = try Data(contentsOf: url)
                
            } catch {
                self.logger.error("An error occured: \(error.localizedDescription)")
            }
            
        } else {
            
            self.logger.error("Could not find a file for the provided information.")
            
            do {
                try await self.loadFixtureIfConfigured()
            } catch {
                print(error)
            }
            
        }
        
        let response = HTTPResponse(request, urlResponse!, data)
        
        return .success(response)
        
    }
    
    func loadFixtureIfConfigured() async throws {
        
        guard let fixtureRequest else {
            print("Checked loading fixture, but it is not provided.")
            return
        }
        
        let loader = URLSessionLoader()
        let result = await loader.load(fixtureRequest)
        
        switch result {
            case .success(let response):
                try self.writeToFile(data: response.body ?? Data())
                print("Wrote fixture to url: \(fixtureURL?.absoluteString ?? "not configured")")
                
            case .failure(let error):
                print(error)
        }
        
    }
    
    private func writeToFile(data: Data) throws {
        
        guard let fixtureURL else {
            return
        }
        
        try prettyPrint(data: data).write(to: fixtureURL)
        
    }
    
    private func prettyPrint(data: Data) throws -> Data {
        
        // Convert the Data variable to a JSON object
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        // Convert the JSON object to a pretty-printed JSON string
        let prettyPrintedData = try JSONSerialization.data(
            withJSONObject: jsonObject,
            options: [.prettyPrinted, .sortedKeys]
        )
        
        return prettyPrintedData
        
    }
    
}
