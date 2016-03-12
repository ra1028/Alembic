import Foundation

public struct JSON {
    public let raw: AnyObject
    
    public init(_ raw: AnyObject) {
        self.raw = raw
    }
    
    public init(data: NSData, options: NSJSONReadingOptions = .AllowFragments) throws {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: options)
            self.init(json)
        } catch {
            throw DistilError.TypeMismatch(expectedType: NSData.self, actual: data)
        }
    }
    
    public init (string: String, encoding: NSStringEncoding = NSUTF8StringEncoding, allowLossyConversion: Bool = false, options: NSJSONReadingOptions = .AllowFragments) throws {
        guard let json = string.dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion) else {
            throw DistilError.TypeMismatch(expectedType: String.self, actual: string)
        }
        try self.init(data: json, options: options)
    }
}

// MARK: - distil value functions

public extension JSON {
    func distil<T: Distillable>(_: T.Type = T.self) throws -> T {
        return try T.distil(self)
    }
    
    func distil<T: Distillable>(path: JSONPath) -> T.Type throws -> T {
        return { _ in
            do {
                return try JSON(self.distilRecursive(path)).distil()
            } catch let DistilError.MissingPath(missing) where path != missing {
                throw DistilError.MissingPath(path + missing)
            }
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) throws -> T {
        return try distil(path)(T)
    }
    
    func distil<T: Distillable>(_: T.Type = T.self) -> DistilResult<T> {
        return DistilResult() {
            try self.distil()
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> T.Type -> DistilResult<T> {
        return { _ in
            DistilResult() {
                try self.distil(path)
            }
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> DistilResult<T> {
        return distil(path)(T)
    }
}

// MARK: - distil optional value functions

public extension JSON {
    func optional<T: Distillable>(path: JSONPath) -> Optional<T>.Type throws -> Optional<T> {
        return { _ in
            do {
                return try self.distil(path)(T)
            } catch let DistilError.MissingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func optional<T: Distillable>(path: JSONPath) throws -> Optional<T> {
        return try optional(path)(Optional<T>)
    }
    
    func optional<T: Distillable>(path: JSONPath) -> Optional<T>.Type -> DistilResult<Optional<T>> {
        return { _ in
            DistilResult() {
                try self.optional(path)
            }
        }
    }
    
    func optional<T: Distillable>(path: JSONPath) -> DistilResult<Optional<T>> {
        return optional(path)(Optional<T>)
    }
}

// MARK: - distil array functions

public extension JSON {
    func distil<T: Distillable>(_: [T].Type = [T].self) throws -> [T] {
        let array: [AnyObject] = try cast(raw)
        return try array.map { try JSON($0).distil() }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> [T].Type throws -> [T] {
        return { _ in
            let array: [AnyObject] = try self.distilRecursive(path)
            return try JSON(array).distil()
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) throws -> [T] {
        return try distil(path)([T])
    }
    
    func distil<T: Distillable>(_: [T].Type = [T].self) -> DistilResult<[T]> {
        return DistilResult() {
            try self.distil()
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> [T].Type -> DistilResult<[T]> {
        return { _ in
            DistilResult() {
                try self.distil(path)
            }
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> DistilResult<[T]> {
        return distil(path)([T])
    }
}

// MARK: - distil optional array functions

public extension JSON {
    func optional<T: Distillable>(path: JSONPath) -> Optional<[T]>.Type throws -> Optional<[T]> {
        return { _ in
            do {
                return try self.distil(path)([T])
            } catch let DistilError.MissingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func optional<T: Distillable>(path: JSONPath) throws -> Optional<[T]> {
        return try optional(path)(Optional<[T]>)
    }
    
    func optional<T: Distillable>(path: JSONPath) -> Optional<[T]>.Type -> DistilResult<Optional<[T]>> {
        return { _ in
            DistilResult() {
                try self.optional(path)
            }
        }
    }
    
    func optional<T: Distillable>(path: JSONPath) -> DistilResult<Optional<[T]>> {
        return optional(path)(Optional<[T]>)
    }
}

// MARK: - distil dictionary functions

public extension JSON {
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) throws -> [String: T] {
        let dictionary: [String: AnyObject] = try cast(raw)
        return try dictionary.reduce([String: T](minimumCapacity: dictionary.count)) { (var new, old) in
            let value: T = try JSON(old.1).distil()
            new[old.0] = value
            return new
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> [String: T].Type throws -> [String: T] {
        return { _ in
            let dictionary: [String: AnyObject] = try self.distilRecursive(path)
            return try JSON(dictionary).distil()
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) throws -> [String: T] {
        return try distil(path)([String: T])
    }
    
    func distil<T: Distillable>(path: JSONPath) -> [String: T].Type -> DistilResult<[String: T]> {
        return { _ in
            DistilResult() {
                try self.distil(path)([String: T])
            }
        }
    }
    
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) -> DistilResult<[String: T]> {
        return DistilResult() {
            try self.distil()
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> DistilResult<[String: T]> {
        return distil(path)([String: T])
    }
}

// MARK: - distil optional dictionary functions

public extension JSON {
    func optional<T: Distillable>(path: JSONPath) -> Optional<[String: T]>.Type throws -> Optional<[String: T]> {
        return { _ in
            do {
                return try self.distil(path)([String: T])
            } catch let DistilError.MissingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func optional<T: Distillable>(path: JSONPath) throws -> Optional<[String: T]> {
        return try optional(path)(Optional<[String: T]>)
    }
    
    func optional<T: Distillable>(path: JSONPath) -> Optional<[String: T]>.Type -> DistilResult<Optional<[String: T]>> {
        return { _ in
            DistilResult() {
                try self.optional(path)
            }
        }
    }
    
    func optional<T: Distillable>(path: JSONPath) -> DistilResult<Optional<[String: T]>> {
        return optional(path)(Optional<[String: T]>)
    }
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    public var description: String {
        return "JSON(\(raw))"
    }
}

// MARK: - private functions

private extension JSON {
    func distilRecursive<T>(path: JSONPath) throws -> T {
        func distilRecursive(object: AnyObject, _ paths: ArraySlice<JSONPathElement>) throws -> AnyObject {
            guard let firstPath = paths.first else {
                return object
            }
            
            if let key = firstPath.value as? String {
                let dictionary: [String: AnyObject] = try cast(object)
                
                guard let value = dictionary[key] where !(value is NSNull) else {
                    throw DistilError.MissingPath(path)
                }
                
                if paths.count == 1 {
                    return value
                }
                return try distilRecursive(value, paths.dropFirst())
            }
            
            if let index = firstPath.value as? Int {
                let array: [AnyObject] = try cast(object)
                
                guard array.count > index else {
                    throw DistilError.MissingPath(path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw DistilError.MissingPath(path)
                }
                
                if paths.count == 1 {
                    return value
                }                
                return try distilRecursive(value, paths.dropFirst())
            }
            
            fatalError("JSONPathElement value allow String or Int type only")
        }
        
        return try cast(distilRecursive(raw, ArraySlice(path.paths)))
    }
    
    func cast<T>(object: AnyObject) throws -> T {
        guard let value = object as? T else {
            throw DistilError.TypeMismatch(expectedType: T.self, actual: object)
        }
        return value
    }
}