import class Foundation.JSONSerialization
import class Foundation.NSNull
import struct Foundation.Data

public struct JSON {
    public let rawValue: Any
    
    public init(_ rawValue: Any) {
        self.rawValue = rawValue
    }
    
    public init(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        do {
            let rawValue = try JSONSerialization.jsonObject(with: data, options: options)
            self.init(rawValue)
        } catch {
            throw JSON.Error.serializeFailed(value: data)
        }
    }
    
    public init(
        string: String,
        encoding: String.Encoding = .utf8,
        allowLossyConversion: Bool = false,
        options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        guard let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
            throw JSON.Error.serializeFailed(value: string)
        }
        
        do {
            try self.init(data: data, options: options)
        } catch JSON.Error.serializeFailed {
            throw JSON.Error.serializeFailed(value: string)
        }
    }
}

public extension JSON {
    func value<T: Parsable>(_ type: T.Type = T.self, for path: Path = []) throws -> T {
        let value = try retrive(with: path)
        
        do {
            return try .value(from: .init(value))
        } catch let JSON.Error.missing(path: missingPath) {
            throw JSON.Error.missing(path: path + missingPath)
        } catch let JSON.Error.typeMismatch(expected: expected, actualValue: actualValue, path: mismatchPath) {
            throw JSON.Error.typeMismatch(expected: expected, actualValue: actualValue, path: path + mismatchPath)
        } catch let JSON.Error.unexpected(value: value, path: unexpectedPath) {
            throw JSON.Error.unexpected(value: value, path: path + unexpectedPath)
        }
    }
    
    func value<T: Parsable>(_ type: [T].Type = [T].self, for path: Path = []) throws -> [T] {
        return try .value(from: value(for: path))
    }
    
    func value<T: Parsable>(_ type: [String: T].Type = [String: T].self, for path: Path = []) throws -> [String: T] {
        return try .value(from: value(for: path))
    }
    
    func option<T: Parsable>(_ type: T.Type = T.self, for path: Path = []) throws -> T? {
        do {
            return try value(for: path) as T
        } catch let JSON.Error.missing(path: missing) where missing == path {
            return nil
        }
    }
    
    func option<T: Parsable>(_ type: [T].Type = [T].self, for path: Path = []) throws -> [T]? {
        return try option(for: path).map([T].value(from:))
    }
    
    func option<T: Parsable>(_ type: [String: T].Type = [String: T].self, for path: Path = []) throws -> [String: T]? {
        return try option(for: path).map([String: T].value(from:))
    }
}

public extension JSON {
    func parse<T: Parsable>(_ type: T.Type = T.self, for path: Path = []) -> ThrowParsed<T> {
        return .init(path: path) { try self.value(for: path) }
    }
    
    func parse<T: Parsable>(_ type: [T].Type = [T].self, for path: Path = []) -> ThrowParsed<[T]> {
        return .init(path: path) { try self.value(for: path) }
    }
    
    func parse<T: Parsable>(_ type: [String: T].Type = [String: T].self, for path: Path = []) -> ThrowParsed<[String: T]> {
        return .init(path: path) { try self.value(for: path) }
    }
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    public var description: String {
        return "JSON(\(rawValue))"
    }
}

// MARK: - CustomDebugStringConvertible

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByArrayLiteral

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = [String: Any](uniqueKeysWithValues: elements)
        self.init(dictionary)
    }
}

// MARK: - private functions

private extension JSON {
    @inline(__always)
    func retrive(with path: Path) throws -> Any {
        @inline(__always)
        func retrive(from value: Any, with pathElements: ArraySlice<Path.Element>) throws -> Any {
            guard let first = pathElements.first else { return value }
            
            switch first {
            case let .key(key):
                guard let dictionary = value as? [String: Any], let value = dictionary[key], !(value is NSNull) else {
                    throw JSON.Error.missing(path: path)
                }
                
                return try retrive(from: value, with: pathElements.dropFirst())
                
            case let .index(index):
                guard let array = value as? [Any], array.count > index else {
                    throw JSON.Error.missing(path: path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw JSON.Error.missing(path: path)
                }
                
                return try retrive(from: value, with: pathElements.dropFirst())
            }
        }
        
        let pathElements = ArraySlice(path.elements)
        return try retrive(from: rawValue, with: pathElements)
    }
}
