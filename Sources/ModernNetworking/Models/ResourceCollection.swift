//
//  ResourceCollection.swift
//  
//
//  Created by Lennart Fischer on 13.01.21.
//

import Foundation

public struct ResourceCollection<T: Model>: Codable {
    
    public let data: [T]
    public let links: ResourceLinks
    public let meta: ResourceMeta
    
    public init(data: [T], links: ResourceLinks, meta: ResourceMeta) {
        self.data = data
        self.links = links
        self.meta = meta
    }
    
}

public struct ResourceLinks: Codable {
    
    public let first: String?
    public let last: String?
    public let previous: String?
    public let next: String?
    
    public enum CodingKeys: String, CodingKey {
        case first = "first"
        case last = "last"
        case previous = "prev"
        case next = "next"
    }
    
    public init(first: String? = nil, last: String? = nil, previous: String? = nil, next: String? = nil) {
        self.first = first
        self.last = last
        self.previous = previous
        self.next = next
    }
    
}

public struct ResourceMeta: Codable {
    
    public let currentPage: Int?
    public let from: Int?
    public let lastPage: Int?
    public let links: [PageLink]
    public let path: String?
    public let perPage: Int?
    public let to: Int?
    public let total: Int?
    
    public enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from = "from"
        case lastPage = "last_page"
        case links = "links"
        case path = "path"
        case perPage = "per_page"
        case to = "to"
        case total = "total"
    }
    
    public init(
        currentPage: Int? = nil,
        from: Int? = nil,
        lastPage: Int = 1,
        links: [PageLink] = [],
        path: String = "",
        perPage: Int = 10,
        to: Int? = 1,
        total: Int? = 10
    ) {
        self.currentPage = currentPage
        self.from = from
        self.lastPage = lastPage
        self.links = links
        self.path = path
        self.perPage = perPage
        self.to = to
        self.total = total
    }
    
}

public struct PageLink: Codable {
    public let url: String?
//    public let label: Int
    public let active: Bool
}

extension ResourceCollection: Model {
    public static var decoder: JSONDecoder { T.decoder }
    public static var encoder: JSONEncoder { T.encoder }
}
