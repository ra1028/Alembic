public protocol Initializable: Decodable {
    init(with json: JSON) throws
}

public extension Initializable {
    static func value(from json: JSON) throws -> Self {
        return try .init(with: json)
    }
}
