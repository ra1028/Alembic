public protocol Brewable: Decodable {
    init(with json: JSON) throws
}

public extension Brewable {
    static func value(from json: JSON) throws -> Self {
        return try .init(with: json)
    }
}
