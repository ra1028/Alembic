import class Foundation.JSONSerialization
import class Foundation.NSNull
import struct Foundation.Data

public final class JSON {
    public let raw: Any
    
    private let create: () throws -> Any
    private var cachedJsonObject: Any?
    
    public convenience init(_ raw: Any) {
        self.init(raw: raw) { raw }
    }
    
    public convenience init(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) {
        self.init(raw: data) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: options)
            } catch {
                throw DecodeError.serializeFailed(with: data)
            }
        }
    }
    
    public convenience init(
        string: String,
        encoding: String.Encoding = .utf8,
        allowLossyConversion: Bool = false,
        options: JSONSerialization.ReadingOptions = .allowFragments) {
        self.init(raw: string) {
            guard let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
                throw DecodeError.serializeFailed(with: string)
            }
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: options)
            } catch {
                throw DecodeError.serializeFailed(with: string)
            }
        }
    }
    
    private init(raw: Any, create: @escaping () throws -> Any) {
        self.raw = raw
        self.create = create
    }
    
    fileprivate func jsonObject() throws -> Any {
        if let cachedJsonObject = cachedJsonObject { return cachedJsonObject }
        let jsonObject = try create()
        cachedJsonObject = jsonObject
        return jsonObject
    }
}

public extension JSON {
    func value<T: Decodable>(for path: Path = []) throws -> T {
        let object: Any = try decodeRecursive(path: path)
        
        do {
            return try .value(from: .init(object))
        } catch let DecodeError.missingPath(missing) {
            throw DecodeError.missingPath(path + missing)
        } catch let DecodeError.typeMismatch(expected: expected, actual: actual, path: mismatchPath) {
            throw DecodeError.typeMismatch(expected: expected, actual: actual, path: path + mismatchPath)
        }
    }
    
    func value<T: Decodable>(for path: Path = []) throws -> [T] {
        return try .value(from: value(for: path))
    }
    
    func value<T: Decodable>(for path: Path = []) throws -> [String: T] {
        return try .value(from: value(for: path))
    }
    
    func option<T: Decodable>(for path: Path = []) throws -> T? {
        do {
            return try value(for: path) as T
        } catch let DecodeError.missingPath(missing) where missing == path {
            return nil
        }
    }
    
    func option<T: Decodable>(for path: Path = []) throws -> [T]? {
        return try option(for: path).map([T].value(from:))
    }
    
    func option<T: Decodable>(for path: Path = []) throws -> [String: T]? {
        return try option(for: path).map([String: T].value(from:))
    }
}

public extension JSON {
    func decodeValue<T: Decodable>(for path: Path = [], as: T.Type = T.self) -> ThrowableDecoded<T> {
        return .init { try self.value(for: path) }
    }
    
    func decodeValue<T: Decodable>(for path: Path = [], as: [T].Type = [T].self) -> ThrowableDecoded<[T]> {
        return .init { try self.value(for: path) }
    }
    
    func decodeValue<T: Decodable>(for path: Path = [], as: [String: T].Type = [String: T].self) -> ThrowableDecoded<[String: T]> {
        return .init { try self.value(for: path) }
    }
    
    func decodeOption<T: Decodable>(for path: Path = [], as: T?.Type = T?.self) -> ThrowableDecoded<T?> {
        return .init { try self.option(for: path) }
    }
    
    func decodeOption<T: Decodable>(for path: Path = [], as: [T]?.Type = [T]?.self) -> ThrowableDecoded<[T]?> {
        return .init { try self.option(for: path) }
    }
    
    func decodeOption<T: Decodable>(for path: Path = [], as: [String: T]?.Type = [String: T]?.self) -> ThrowableDecoded<[String: T]?> {
        return .init { try self.option(for: path) }
    }
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    public var description: String {
        return "JSON(\(raw))"
    }
}

// MARK: - CustomDebugStringConvertible

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - private functions

private extension JSON {
    func decodeRecursive<T>(path: Path) throws -> T {
        func cast<T>(_ object: Any) throws -> T {
            guard let value = object as? T else {
                throw DecodeError.typeMismatch(expected: T.self, actual: object, path: path)
            }
            return value
        }
        
        func decodeRecursive(object: Any, elements: ArraySlice<Path.Element>) throws -> Any {
            guard let first = elements.first else { return object }
            
            switch first {
            case let .key(key):
                let dictionary: [String: Any] = try cast(object)
                
                guard let value = dictionary[key], !(value is NSNull) else {
                    throw DecodeError.missingPath(path)
                }
                
                return try decodeRecursive(object: value, elements: elements.dropFirst())
                
            case let .index(index):
                let array: [Any] = try cast(object)
                
                guard array.count > index else {
                    throw DecodeError.missingPath(path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw DecodeError.missingPath(path)
                }
                
                return try decodeRecursive(object: value, elements: elements.dropFirst())
            }
        }
        
        let object = try jsonObject()
        let elements = ArraySlice(path.elements)
        return try cast(decodeRecursive(object: object, elements: elements))
    }
}
