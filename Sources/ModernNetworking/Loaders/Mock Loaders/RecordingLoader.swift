//
//  RecordingLoader.swift
//  
//
//  Created by Lennart Fischer on 01.05.23.
//

import Foundation
import OSLog

enum RecordingError: Error {
    
    case cannotFindSimulatorHomeDirectory
    case cannotRunOnPhysicalDevice
    
}

@available(iOS 14.0, *)
public class RecordingLoader: MockLoader {
    
    private let logger: Logger
    
    public static var defaultTestBundle: Bundle? {
        return Bundle.allBundles.first { $0.bundlePath.hasSuffix(".xctest") }
    }
    
    public init(logger: Logger = Logging.logger(for: "RecordingLoader")) {
        self.logger = logger
        super.init()
        self.setup()
    }
    
    private var cacheDirectory: URL!
    private var recordingDirectory: URL!
    
    // MARK: - Setup
    
    private func setup() {
        
        do {
            self.cacheDirectory = try Self.getCacheDirectory()
            self.recordingDirectory = cacheDirectory.appendingPathComponent("Recordings", isDirectory: true)
            
            try FileManager.default.createDirectory(at: recordingDirectory, withIntermediateDirectories: true)
            
            self.logger.info("Configured recording directory at: \(self.recordingDirectory.absoluteURL)")
            
        } catch {
            fatalError("Attention")
        }
        
    }
    
    // MAKR: - Loading
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        if let storedResponse = checkExistingResponse(for: request) {
            self.logger.info("Using stored response for request \(request.url?.absoluteString ?? "unknown")")
            return HTTPResult.success(storedResponse)
        }
        
        guard let nextLoader else {
            return await super.load(request)
        }
        
        let response = await nextLoader.load(request)
        
        do {
            try self.store(result: response)
        } catch {
            self.logger.error("\(error.localizedDescription)")
        }
        
        return response
        
    }
    
    func checkExistingResponse(for request: HTTPRequest) -> HTTPResponse? {
        
        guard let bundle = Self.defaultTestBundle else {
            return nil
        }
        
        guard let fixtureURL = bundle.url(forResource: fileName(request: request), withExtension: ".json") else {
            return nil
        }
        
        do {
            guard let requestURL = request.url else { return nil }
            
            let urlResponse = HTTPURLResponse(
                url: requestURL,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: [:]
            )
            
            let data = try Data(contentsOf: fixtureURL)
            
            guard let urlResponse else { return nil }
            return HTTPResponse(request, urlResponse, data)
            
        } catch {
            self.logger.error("\(error.localizedDescription)")
        }
        
        return nil
        
    }
    
    func fileName(request: HTTPRequest) -> String {

        let headers = request.headers.values.joined(separator: ",")
        
        return "(\(request.method.name)) \(request.host ?? "Default") \(request.path) \(headers)"
//            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            .replacingOccurrences(of: "/", with: "_")
        
    }
    
    func store(result: HTTPResult) throws {
        
        switch result {
            case .success(let response):
                if let body = response.body {
                    
                    let file = "\(fileName(request: response.request)).json" // .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                    let url = recordingDirectory.appendingPathComponent(file)
                    
                    try body.write(to: url, options: [])
                    
//                    FileManager.default.createFile(
//                        atPath: recordingDirectory.appendingPathComponent("abc.json").path,
//                        contents: body
//
                    
//                    try body.write(to: recordingDirectory.appendingPathComponent("abc.json"))
                }
                
            case .failure(_):
                break
        }
        
    }
    
    class func getCacheDirectory() throws -> URL {
        let cachePath = "Library/Caches/ModernNetworking"
        // on OSX config is stored in /Users/<username>/Library
        // and on iOS/tvOS/WatchOS it's in simulator's home dir
#if os(OSX)
        let homeDir = URL(fileURLWithPath: NSHomeDirectory())
        return homeDir.appendingPathComponent(cachePath)
#elseif arch(i386) || arch(x86_64) || arch(arm64)
        guard let simulatorHostHome = ProcessInfo().environment["SIMULATOR_HOST_HOME"] else {
            throw RecordingError.cannotFindSimulatorHomeDirectory
        }
        let homeDir = URL(fileURLWithPath: simulatorHostHome)
        return homeDir.appendingPathComponent(cachePath)
#else
        throw RecordingError.cannotRunOnPhysicalDevice
#endif
    }
    
}
