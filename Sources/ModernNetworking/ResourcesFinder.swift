//
//  ResourcesFinder.swift
//  
//
//  Created by Lennart Fischer on 02.04.23.
//

import Foundation

public final class ResourcesFinder {
    
    let url: URL
    let rootFilename: String
    let resourcesDir: String
    
    public init(
        url: URL = URL(fileURLWithPath: #file),
        rootFilename: String = "Package.swift",
        resourcesDir: String = "Resources"
    ) {
        self.url = url
        self.rootFilename = rootFilename
        self.resourcesDir = resourcesDir
    }
    
    public init(
        file: String,
        rootFilename: String = "Package.swift",
        resourcesDir: String = "Resources"
    ) {
        self.url = URL(fileURLWithPath: file)
        self.rootFilename = rootFilename
        self.resourcesDir = resourcesDir
    }
    
    public func resourcesURL() -> URL? {

        return baseURL()?.appendingPathComponent(resourcesDir)

    }
    
    public func baseURL() -> URL? {
        
        guard let rootURL = findUp(filename: rootFilename, baseURL: url.deletingLastPathComponent()) else {
            return nil
        }
        return rootURL
        
    }
    
    func findUp(filename: String, baseURL: URL) -> URL? {
        let fileURL = baseURL.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return baseURL
        } else {
            return baseURL.pathComponents.count > 1
            ? findUp(filename: filename, baseURL: baseURL.deletingLastPathComponent())
            : nil
        }
    }
    
}
