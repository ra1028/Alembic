public extension JSON {
    public struct Path {
        public enum Element {
            case key(String)
            case index(Int)
        }
        
        public let elements: [Element]
        
        public init(element: Element) {
            elements = [element]
        }
        
        public init(elements: [Element]) {
            self.elements = elements
        }
    }
}

// MARK: - Equatable

extension JSON.Path: Equatable {
    public static func == (lhs: JSON.Path, rhs: JSON.Path) -> Bool {
        return lhs.elements == rhs.elements
    }
    
    public static func + (lhs: JSON.Path, rhs: JSON.Path) -> JSON.Path {
        return .init(elements: lhs.elements + rhs.elements)
    }
}

extension JSON.Path.Element: Equatable {
    public static func == (lhs: JSON.Path.Element, rhs: JSON.Path.Element) -> Bool {
        switch (lhs, rhs) {
        case let (.key(lKey), .key(rKey)): return lKey == rKey
        case let (.index(lIndex), .index(rIndex)): return lIndex == rIndex
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension JSON.Path: CustomStringConvertible {
    public var description: String {
        return "Path(\(elements))"
    }
}

extension JSON.Path.Element: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .key(key): return "\(key)"
        case let .index(index): return "\(index)"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension JSON.Path: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

extension JSON.Path.Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByStringLiteral

extension JSON.Path: ExpressibleByStringLiteral {
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

extension JSON.Path.Element: ExpressibleByStringLiteral {
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

extension JSON.Path: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(element: .index(value))
    }
}

extension JSON.Path.Element: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension JSON.Path: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements: elements)
    }
}
