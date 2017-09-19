public protocol ParseInitializable: Parsable {
    init(with json: JSON) throws
}

public extension ParseInitializable {
    static func value(from json: JSON) throws -> Self {
        return try .init(with: json)
    }
}
