//
//  EntityTagLoader.swift
//  
//
//  Created by Lennart Fischer on 27.05.22.
//

import Foundation
import OSLog

public protocol EntityTagCaching: Sendable {
    func store(entityTag: String, for url: URL) async
    func loadEntityTag(for url: URL) async -> String?
}

public actor BasicEntityTagCache: EntityTagCaching {
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let cacheFileURL: URL
    private var tagsCache: [String: String]?
    
    public init(cacheFileURL: URL? = nil) {
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        self.cacheFileURL = cacheFileURL ?? Self.defaultCacheFileURL()
    }
    
    public func store(entityTag: String, for url: URL) async {
        var tags = loadTags()
        tags[url.absoluteString] = entityTag
        persist(tags: tags)
    }
    
    public func loadEntityTag(for url: URL) async -> String? {
        loadTags()[url.absoluteString]
    }
    
    private func loadTags() -> [String: String] {
        if let tagsCache {
            return tagsCache
        }

        guard let data = try? Data(contentsOf: cacheFileURL) else {
            tagsCache = [:]
            return [:]
        }

        guard let tags = try? decoder.decode([String: String].self, from: data) else {
            tagsCache = [:]
            return [:]
        }

        tagsCache = tags
        return tags
    }
    
    private func persist(tags: [String: String]) {
        tagsCache = tags
        guard let data = try? encoder.encode(tags) else { return }
        try? data.write(to: cacheFileURL, options: .atomic)
    }

    private static func defaultCacheFileURL() -> URL {
        let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return baseURL.appendingPathComponent("modernnetworking_entity_tags.json")
    }
    
}

public class EntityTagLoader: HTTPLoader {
    
    private let logger: Logger
    private let cache: any EntityTagCaching
    
    public init(cache: any EntityTagCaching = BasicEntityTagCache()) {
        
        self.logger = Logger(.default)
        self.cache = cache
        
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        var copy = request
        
        if let url = copy.url, let entityTag = await loadEntityTag(for: url) {
            copy.headers["If-None-Match"] = entityTag
        }
        
        let result = await super.load(copy)
        
        switch result {
            case .success(let response):
                let entityTag = response.headers["Etag"] as? String
                    ?? response.headers["ETag"] as? String

                if let entityTag, let url = result.request.url {
                    await self.store(entityTag: entityTag, for: url)
                }
            case .failure:
                break
        }
        
        return result
    }
    
    private func store(entityTag: String, for url: URL) async {
        
        logger.info("Caching entity tag '\(entityTag)' for url '\(url.absoluteString)' ")
        
        await cache.store(entityTag: entityTag, for: url)
        
    }
    
    private func loadEntityTag(for url: URL) async -> String? {
        
        if let cached = await cache.loadEntityTag(for: url) {
            
            logger.info("Found entity tag '\(cached)' for url '\(url.absoluteString)' ")
            
            return String(cached)
        }
        
        return nil
        
    }
    
}
