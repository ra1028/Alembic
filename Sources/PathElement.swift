public extension Path {
    enum Element {
        case key(String)
        case index(Int)
    }
}

// MARK: - Equatable

extension Path.Element: Equatable {
    public static func == (lhs: Path.Element, rhs: Path.Element) -> Bool {
        switch (lhs, rhs) {
        case let (.key(lKey), .key(rKey)): return lKey == rKey
        case let (.index(lIndex), .index(rIndex)): return lIndex == rIndex
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Path.Element: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .key(key): return "\(key)"
        case let .index(index): return "\(index)"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension Path.Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByStringLiteral

extension Path.Element: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .key(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .key(value)
    }
    
    public init(stringLiteral value: String) {
        self = .key(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Path.Element: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}
