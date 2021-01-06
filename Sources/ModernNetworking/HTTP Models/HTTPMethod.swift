import Foundation

/// This is a struct instead of an enum, because technically infinite number of HTTP methods can be defined,
/// and using enum only allows for finite number of values.
public struct HTTPMethod: Hashable {

    public static let get = HTTPMethod("GET")
    public static let post = HTTPMethod("POST")
    public static let put = HTTPMethod("PUT")
    public static let delete = HTTPMethod("DELETE")

    public init(_ name: String) {
        self.name = name
    }

    public let name: String

}

// MARK: - CustomStringConvertible API

extension HTTPMethod: CustomStringConvertible {

    public var description: String {
        name
    }

}
