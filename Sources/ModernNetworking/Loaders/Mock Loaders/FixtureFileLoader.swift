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
        fixtureRequest: HTTPRequest? = nil,
        logger: Logger = Logging.logger(for: "FixtureFileLoader")
    ) {
        self.logger = logger
        self.statusCode = statusCode
        self.fixtureURL = fixtureURL
        self.fixtureRequest = fixtureRequest
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        guard let url = request.url else {
            return .failure(HTTPError(.invalidRequest(.invalidURL), request))
        }

        guard let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: [:]
        ) else {
            return .failure(HTTPError(.invalidResponse, request))
        }
        
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
                self.logger.error("Failed to load fixture: \(error.localizedDescription)")
            }
            
        }
        
        return .success(HTTPResponse(request, urlResponse, data))
        
    }
    
    func loadFixtureIfConfigured() async throws {
        
        guard let fixtureRequest else {
            self.logger.info("Checked loading fixture, but it is not provided.")
            return
        }
        
        let loader = URLSessionLoader()
        let result = await loader.load(fixtureRequest)
        
        switch result {
            case .success(let response):
                try self.writeToFile(data: response.body ?? Data())
                self.logger.info("Wrote fixture to url: \(self.fixtureURL?.absoluteString ?? "not configured")")
                
            case .failure(let error):
                self.logger.error("Failed to load fixture: \(error.localizedDescription)")
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
