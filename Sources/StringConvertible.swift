public protocol StringConvertible {
    var stringValue: String { get }
}

extension String: StringConvertible {
    public var stringValue: String {
        return self
    }
}
