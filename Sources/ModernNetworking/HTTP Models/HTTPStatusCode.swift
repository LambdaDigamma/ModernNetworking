import Foundation

public struct HTTPStatusCode: Hashable {

    public static let ok = HTTPStatusCode(value: 200)
    public static let created = HTTPStatusCode(value: 201)
    public static let movedPermanently = HTTPStatusCode(value: 301)
    public static let badRequest = HTTPStatusCode(value: 400)
    public static let unauthorized = HTTPStatusCode(value: 401)
    public static let forbidden = HTTPStatusCode(value: 403)
    public static let notFound = HTTPStatusCode(value: 404)
    public static let internalServerError = HTTPStatusCode(value: 500)
    
    public let value: Int
    
    public init(value: Int) {
        self.value = value
    }

}

// MARK: - CustomStringConvertible API

extension HTTPStatusCode: CustomStringConvertible {

    public var description: String {
        "\(value)"
    }

}
