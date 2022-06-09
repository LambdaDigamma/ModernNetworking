//
//  EntityTagLoader.swift
//  
//
//  Created by Lennart Fischer on 27.05.22.
//

import Foundation
import OSLog

public protocol EntityTagCaching {
    
    func store(entityTag: String, for url: URL)
    
    func loadEntityTag(for url: URL) -> String?
    
}

public class BasicEntityTagCache: EntityTagCaching {
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init() {
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    public func store(entityTag: String, for url: URL) {
        
        guard let url = cacheUrl() else { return }
        
        var tags = loadTags()
        tags[url.absoluteString] = entityTag
        
        guard let data = try? encoder.encode(tags) else { return }
        try? data.write(to: url)
        
    }
    
    public func loadEntityTag(for url: URL) -> String? {
        
        if let tag = loadTags()[url.absoluteString] {
            return tag
        }
        
        return nil
        
    }
    
    private func loadTags() -> [String: String] {
        
        guard let url = cacheUrl() else { return [:] }
        guard let data = try? Data(contentsOf: url) else { return [:] }
        guard let tags = try? decoder.decode([String: String].self, from: data) else { return [:] }
        
        return tags
        
    }
    
    private func cacheUrl() -> URL? {
        
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first?.appendingPathComponent("entity_tags.json")
        
    }
    
}

public class EntityTagLoader: HTTPLoader {
    
    private let logger: Logger
    private let cache: EntityTagCaching
    
    public init(cache: EntityTagCaching = BasicEntityTagCache()) {
        
        self.logger = Logger(.default)
        self.cache = cache
        
    }
    
    public override func load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {
        
        var copy = request
        
        if let url = copy.url, let entityTag = loadEntityTag(for: url) {
            copy.headers["If-None-Match"] = entityTag
        }
        
        super.load(copy, completion: { result in
            
//            print(result.response?.headers)
//            print(result.response?.headers["Etag"] as? String)
//            print(result.request.url)
            
            if let entityTag = result.response?.headers["Etag"] as? String, let url = result.request.url {
                self.store(entityTag: entityTag, for: url)
            }
            
            switch result {
                case .success(let response):
                    guard let data = response.body else { return }
                    print(String(decoding: data, as: UTF8.self))
                case .failure(let error):
                    print("Failed with error:")
                    print(error)
                    print(error.underlyingError ?? "")
            }
            
            completion(result)
        })
        
    }
    
    private func store(entityTag: String, for url: URL) {
        
        logger.info("Caching entity tag '\(entityTag)' for url '\(url.absoluteString)' ")
        
        cache.store(entityTag: entityTag, for: url)
        
    }
    
    private func loadEntityTag(for url: URL) -> String? {
        
        if let cached = cache.loadEntityTag(for: url) {
            
            logger.info("Found entity tag '\(cached)' for url '\(url.absoluteString)' ")
            
            return String(cached)
        }
        
        return nil
        
    }
    
}
