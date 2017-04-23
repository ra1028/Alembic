public protocol Brewable: Distillable {
    init(json j: JSON) throws
}

public extension Brewable {
    static func distil(json j: JSON) throws -> Self {
        return try .init(json: j)
    }
}
