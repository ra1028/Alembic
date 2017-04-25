public struct Path {
    public let elements: [Element]
    
    public init(element: Element) {
        elements = [element]
    }
    
    public init(elements: [Element]) {
        self.elements = elements
    }
}

// MARK: - Equatable

extension Path: Equatable {
    public static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.elements == rhs.elements
    }
    
    public static func + (lhs: Path, rhs: Path) -> Path {
        return .init(elements: lhs.elements + rhs.elements)
    }
}

// MARK: - CustomStringConvertible

extension Path: CustomStringConvertible {
    public var description: String {
        return "Path(\(elements))"
    }
}

// MARK: - CustomDebugStringConvertible

extension Path: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByStringLiteral

extension Path: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: String) {
        self.init(element: .key(value))
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(element: .key(value))
    }
    
    public init(stringLiteral value: String) {
        self.init(element: .key(value))
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Path: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(element: .index(value))
    }
}

// MARK: - ExpressibleByArrayLiteral

extension Path: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements: elements)
    }
}
