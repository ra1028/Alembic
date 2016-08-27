//
//  JSON.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct JSON {
    public let raw: Any
    
    public subscript(path: JSONPathElement) -> DistillSubscripted {
        return .init(self, JSONPath(path))
    }
    
    public subscript(path: JSONPathElement...) -> DistillSubscripted {
        return .init(self, JSONPath(path))
    }
    
    public init(_ raw: Any) {
        self.raw = raw
    }
    
    public init(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: options)
            self.init(json)
        } catch {
            throw DistillError.typeMismatch(expected: Data.self, actual: data)
        }
    }
    
    public init (string: String, encoding: String.Encoding = String.Encoding.utf8, allowLossyConversion: Bool = false, options: JSONSerialization.ReadingOptions = .allowFragments) throws {
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
    func distil<T: Distillable>(_: T.Type = T.self) throws -> T {
        return try T.distil(self)
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> (T.Type) throws -> T {
        return { _ in
            do {
                let object: Any = try self.distilRecursive(path)
                return try JSON(object).distil()
            } catch let DistillError.missingPath(missing) where path != missing {
                throw DistillError.missingPath(path + missing)
            }
        }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) throws -> T {
        return try distil(path)(T)
    }
    
    func distil<T: Distillable>(_: T.Type = T.self) -> InsecureDistillate<T> {
        return InsecureDistillate { try self.distil() }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> (T.Type) -> InsecureDistillate<T> {
        return { _ in InsecureDistillate { try self.distil(path) } }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> InsecureDistillate<T> {
        return distil(path)(T)
    }
}

// MARK: - distil option value functions

public extension JSON {
    func option<T: Distillable>(_ path: JSONPath) -> (Optional<T>.Type) throws -> Optional<T> {
        return { _ in
            do {
                return try self.distil(path)(T)
            } catch let DistillError.typeMismatch(expected: _, actual: actual) {
                throw DistillError.typeMismatch(expected: Optional<T>.self, actual: actual)
            } catch let DistillError.missingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func option<T: Distillable>(_ path: JSONPath) throws -> Optional<T> {
        return try option(path)(Optional<T>)
    }
    
    func option<T: Distillable>(_ path: JSONPath) -> (Optional<T>.Type) -> InsecureDistillate<Optional<T>> {
        return { _ in InsecureDistillate { try self.option(path) } }
    }
    
    func option<T: Distillable>(_ path: JSONPath) -> InsecureDistillate<Optional<T>> {
        return option(path)(Optional<T>)
    }
}

// MARK: - distil array functions

public extension JSON {
    func distil<T: Distillable>(_: [T].Type = [T].self) throws -> [T] {
        let array: [Any] = try cast(raw)
        return try array.map { try JSON($0).distil() }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> ([T].Type) throws -> [T] {
        return { _ in
            let array: [Any] = try self.distilRecursive(path)
            return try JSON(array as Any).distil()
        }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) throws -> [T] {
        return try distil(path)([T])
    }
    
    func distil<T: Distillable>(_: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return InsecureDistillate { try self.distil() }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> ([T].Type) -> InsecureDistillate<[T]> {
        return { _ in InsecureDistillate { try self.distil(path) } }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> InsecureDistillate<[T]> {
        return distil(path)([T])
    }
}

// MARK: - distil option array functions

public extension JSON {
    func option<T: Distillable>(_ path: JSONPath) -> (Optional<[T]>.Type) throws -> Optional<[T]> {
        return { _ in
            do {
                return try self.distil(path)([T])
            } catch let DistillError.typeMismatch(expected: _, actual: actual) {
                throw DistillError.typeMismatch(expected: Optional<[T]>.self, actual: actual)
            } catch let DistillError.missingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func option<T: Distillable>(_ path: JSONPath) throws -> Optional<[T]> {
        return try option(path)(Optional<[T]>)
    }
    
    func option<T: Distillable>(_ path: JSONPath) -> (Optional<[T]>.Type) -> InsecureDistillate<Optional<[T]>> {
        return { _ in InsecureDistillate { try self.option(path) } }
    }
    
    func option<T: Distillable>(_ path: JSONPath) -> InsecureDistillate<Optional<[T]>> {
        return option(path)(Optional<[T]>)
    }
}

// MARK: - distil dictionary functions

public extension JSON {
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) throws -> [String: T] {
        let dictionary: [String: Any] = try cast(raw)
        var new = [String: T](minimumCapacity: dictionary.count)
        try dictionary.forEach {
            let value: T = try JSON($1).distil()
            new[$0] = value
        }
        return new
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> ([String: T].Type) throws -> [String: T] {
        return { _ in
            let dictionary: [String: Any] = try self.distilRecursive(path)
            return try JSON(dictionary).distil()
        }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) throws -> [String: T] {
        return try distil(path)([String: T])
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> ([String: T].Type) -> InsecureDistillate<[String: T]> {
        return { _ in InsecureDistillate { try self.distil(path)([String: T]) } }
    }
    
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return InsecureDistillate { try self.distil() }
    }
    
    func distil<T: Distillable>(_ path: JSONPath) -> InsecureDistillate<[String: T]> {
        return distil(path)([String: T])
    }
}

// MARK: - distil option dictionary functions

public extension JSON {
    func option<T: Distillable>(_ path: JSONPath) -> (Optional<[String: T]>.Type) throws -> Optional<[String: T]> {
        return { _ in
            do {
                return try self.distil(path)([String: T])
            } catch let DistillError.typeMismatch(expected: _, actual: actual) {
                throw DistillError.typeMismatch(expected: Optional<[String: T]>.self, actual: actual)
            } catch let DistillError.missingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func option<T: Distillable>(_ path: JSONPath) throws -> Optional<[String: T]> {
        return try option(path)(Optional<[String: T]>)
    }
    
    func option<T: Distillable>(_ path: JSONPath) -> (Optional<[String: T]>.Type) -> InsecureDistillate<Optional<[String: T]>> {
        return { _ in InsecureDistillate { try self.option(path) } }
    }
    
    func option<T: Distillable>(_ path: JSONPath) -> InsecureDistillate<Optional<[String: T]>> {
        return option(path)(Optional<[String: T]>)
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
        return String(data: serializeToData(serializable, options: options), encoding: String.Encoding.utf8)!
    }
    
    static func serializeToString(_ serializable: Serializable, rootKey: String, options: JSONSerialization.WritingOptions = []) -> String {
        return String(data: serializeToData(serializable, rootKey: rootKey, options: options), encoding: String.Encoding.utf8)!
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
        return String(data: serializeToData(serializables, options: options), encoding: String.Encoding.utf8)!
    }
    
    static func serializeToString<T: Serializable>(_ serializables: [T], rootKey: String, options: JSONSerialization.WritingOptions = []) -> String {
        return String(data: serializeToData(serializables, rootKey: rootKey, options: options), encoding: String.Encoding.utf8)!
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
    func distilRecursive<T>(_ path: JSONPath) throws -> T {
        func distilRecursive(_ object: Any, _ paths: ArraySlice<JSONPathElement>) throws -> Any {
            switch paths.first {
            case let .key(key)?:
                let dictionary: [String: Any] = try cast(object)
                
                guard let value = dictionary[key] , !(value is NSNull) else {
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
