//
//  JSON.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public final class JSON {
    public let raw: Any
    
    public subscript(path: PathElement) -> Subscripted {
        return .init(self, Path(path))
    }
    
    public subscript(path: PathElement...) -> Subscripted {
        return .init(self, Path(path))
    }
    
    public init(_ raw: Any) {
        self.raw = raw
    }
    
    public convenience init(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: options)
            self.init(json)
        } catch {
            throw DistillError.typeMismatch(expected: Data.self, actual: data)
        }
    }
    
    public convenience init(
        string: String,
        encoding: String.Encoding = .utf8,
        allowLossyConversion: Bool = false,
        options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        guard let json = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
            throw DistillError.typeMismatch(expected: String.self, actual: string)
        }
        try self.init(data: json, options: options)
    }
}

public extension JSON {
    func to<T: Distillable>(_: T.Type) throws -> T {
        return try distil()
    }
    
    func to<T: Distillable>(_: [T].Type) throws -> [T] {
        return try distil()
    }
    
    func to<T: Distillable>(_: [String: T].Type) throws -> [String: T] {
        return try distil()
    }
}

// MARK: - distil value functions

public extension JSON {
    func distil<T: Distillable>(_ path: Path = [], to: T.Type = T.self) throws -> T {
        do {
            let object: Any = try distilRecursive(path)
            return try .distil(JSON(object))
        } catch let DistillError.missingPath(missing) where path != missing {
            throw DistillError.missingPath(path + missing)
        }
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: T.Type = T.self) -> InsecureDistillate<T> {
        return .init { try self.distil(path) }
    }
}

// MARK: - distil option value functions

public extension JSON {
    func option<T: Distillable>(_ path: Path, to: T?.Type = (T?).self) throws -> T? {
        do {
            return try distil(path, to: T.self)
        } catch let DistillError.missingPath(missing) where missing == path {
            return nil
        }
    }
    
    func option<T: Distillable>(_ path: Path, to: T?.Type = (T?).self) -> InsecureDistillate<T?> {
        return .init { try self.option(path) }
    }
}

// MARK: - distil array functions

public extension JSON {
    func distil<T: Distillable>(_ path: Path = [], to: [T].Type = [T].self) throws -> [T] {
        let arr: [Any] = try distilRecursive(path)
        return try arr.map { try JSON($0).distil() }
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try self.distil(path) }
    }
}

// MARK: - distil option array functions

public extension JSON {
    func option<T: Distillable>(_ path: Path, to: [T]?.Type = ([T]?).self) throws -> [T]? {
        do {
            return try distil(path, to: [T].self)
        } catch let DistillError.missingPath(missing) where missing == path {
            return nil
        }
    }
    
    func option<T: Distillable>(_ path: Path, to: [T]?.Type = ([T]?).self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(path) }
    }
}

// MARK: - distil dictionary functions

public extension JSON {
    func distil<T: Distillable>(_ path: Path = [], to: [String: T].Type = [String: T].self) throws -> [String: T] {
        let dic: [String: Any] = try distilRecursive(path)
        var new = [String: T](minimumCapacity: dic.count)
        try dic.forEach { try new.updateValue(JSON($1).distil(), forKey: $0) }
        return new
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try self.distil(path) }
    }
}

// MARK: - distil option dictionary functions

public extension JSON {
    func option<T: Distillable>(_ path: Path, to: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        do {
            return try distil(path, to: [String: T].self)
        } catch let DistillError.missingPath(missing) where missing == path {
            return nil
        }
    }
    
    func option<T: Distillable>(_ path: Path, to: [String: T]?.Type = ([String: T]?).self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(path) }
    }
}

// MARK: - serialize value functions

public extension JSON {
    static func serializeToData(_ serializable: Serializable, options: JSONSerialization.WritingOptions = []) -> Data {
        let serializedObject = serializable.serialize().object
        return serializeToData(object: serializedObject, options: options)
    }
    
    static func serializeToData(_ serializable: Serializable, rootKey: String, options: JSONSerialization.WritingOptions = []) -> Data {
        let serializedObject = serializable.serialize().object
        return serializeToData(object: serializedObject, options: options)
    }
    
    static func serializeToString(_ serializable: Serializable, options: JSONSerialization.WritingOptions = []) -> String {
        return String(data: serializeToData(serializable, options: options), encoding: .utf8)!
    }
    
    static func serializeToString(_ serializable: Serializable, rootKey: String, options: JSONSerialization.WritingOptions = []) -> String {
        return String(data: serializeToData(serializable, rootKey: rootKey, options: options), encoding: .utf8)!
    }
}

// MARK: - serialize array functions

public extension JSON {
    static func serializeToData<T: Serializable>(_ serializables: [T], options: JSONSerialization.WritingOptions = []) -> Data {
        let serializedObjects = serializables.map { $0.serialize().object }
        return serializeToData(object: serializedObjects, options: options)
    }
    
    static func serializeToData<T: Serializable>(_ serializables: [T], rootKey: String, options: JSONSerialization.WritingOptions = []) -> Data {
        let serializedObjects = serializables.map { $0.serialize().object }
        return serializeToData(object: [rootKey: serializedObjects], options: options)
    }
    
    static func serializeToString<T: Serializable>(_ serializables: [T], options: JSONSerialization.WritingOptions = []) -> String {
        return String(data: serializeToData(serializables, options: options), encoding: .utf8)!
    }
    
    static func serializeToString<T: Serializable>(_ serializables: [T], rootKey: String, options: JSONSerialization.WritingOptions = []) -> String {
        return String(data: serializeToData(serializables, rootKey: rootKey, options: options), encoding: .utf8)!
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
    func distilRecursive<T>(_ path: Path) throws -> T {
        func distilRecursive(_ object: Any, _ paths: ArraySlice<PathElement>) throws -> Any {
            switch paths.first {
            case let .key(key)?:
                let dictionary: [String: Any] = try cast(object)
                
                guard let value = dictionary[key], !(value is NSNull) else {
                    throw DistillError.missingPath(path)
                }
                
                return try distilRecursive(value, paths.dropFirst())
                
            case let .index(index)?:
                let array: [Any] = try cast(object)
                
                guard array.count > index else {
                    throw DistillError.missingPath(path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw DistillError.missingPath(path)
                }
                
                return try distilRecursive(value, paths.dropFirst())
                
            case .none:
                return object
            }
        }
        
        return try cast(distilRecursive(raw, ArraySlice(path.paths)))
    }
    
    func cast<T>(_ object: Any) throws -> T {
        guard let value = object as? T else {
            throw DistillError.typeMismatch(expected: T.self, actual: object)
        }
        return value
    }
    
    static func serializeToData(object: Any, options: JSONSerialization.WritingOptions = []) -> Data {
        return try! JSONSerialization.data(withJSONObject: object, options: options)
    }
}
