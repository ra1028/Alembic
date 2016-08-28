//
//  JSON.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct JSON {
    public let raw: AnyObject
    
    public subscript(path: JSONPathElement) -> DistillSubscripted {
        return .init(self, JSONPath(path))
    }
    
    public subscript(path: JSONPathElement...) -> DistillSubscripted {
        return .init(self, JSONPath(path))
    }
    
    public init(_ raw: AnyObject) {
        self.raw = raw
    }
    
    public init(data: NSData, options: NSJSONReadingOptions = .AllowFragments) throws {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: options)
            self.init(json)
        } catch {
            throw DistillError.TypeMismatch(expected: NSData.self, actual: data)
        }
    }
    
    public init (string: String, encoding: NSStringEncoding = NSUTF8StringEncoding, allowLossyConversion: Bool = false, options: NSJSONReadingOptions = .AllowFragments) throws {
        guard let json = string.dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion) else {
            throw DistillError.TypeMismatch(expected: String.self, actual: string)
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
    
    func distil<T: Distillable>(path: JSONPath) -> T.Type throws -> T {
        return { _ in
            do {
                return try JSON(self.distilRecursive(path)).distil()
            } catch let DistillError.MissingPath(missing) where path != missing {
                throw DistillError.MissingPath(path + missing)
            }
        }
    }
    
    func distil<T: Distillable>(path: JSONPath) throws -> T {
        return try distil(path)(T)
    }
    
    func distil<T: Distillable>(_: T.Type = T.self) -> InsecureDistillate<T> {
        return InsecureDistillate { try self.distil() }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> T.Type -> InsecureDistillate<T> {
        return { _ in InsecureDistillate { try self.distil(path) } }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> InsecureDistillate<T> {
        return distil(path)(T)
    }
}

// MARK: - distil option value functions

public extension JSON {
    func option<T: Distillable>(path: JSONPath) -> Optional<T>.Type throws -> Optional<T> {
        return { _ in
            do {
                return try self.distil(path)(T)
            } catch let DistillError.MissingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func option<T: Distillable>(path: JSONPath) throws -> Optional<T> {
        return try option(path)(Optional<T>)
    }
    
    func option<T: Distillable>(path: JSONPath) -> Optional<T>.Type -> InsecureDistillate<Optional<T>> {
        return { _ in InsecureDistillate { try self.option(path) } }
    }
    
    func option<T: Distillable>(path: JSONPath) -> InsecureDistillate<Optional<T>> {
        return option(path)(Optional<T>)
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
    
    func distil<T: Distillable>(_: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return InsecureDistillate { try self.distil() }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> [T].Type -> InsecureDistillate<[T]> {
        return { _ in InsecureDistillate { try self.distil(path) } }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> InsecureDistillate<[T]> {
        return distil(path)([T])
    }
}

// MARK: - distil option array functions

public extension JSON {
    func option<T: Distillable>(path: JSONPath) -> Optional<[T]>.Type throws -> Optional<[T]> {
        return { _ in
            do {
                return try self.distil(path)([T])
            } catch let DistillError.MissingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func option<T: Distillable>(path: JSONPath) throws -> Optional<[T]> {
        return try option(path)(Optional<[T]>)
    }
    
    func option<T: Distillable>(path: JSONPath) -> Optional<[T]>.Type -> InsecureDistillate<Optional<[T]>> {
        return { _ in InsecureDistillate { try self.option(path) } }
    }
    
    func option<T: Distillable>(path: JSONPath) -> InsecureDistillate<Optional<[T]>> {
        return option(path)(Optional<[T]>)
    }
}

// MARK: - distil dictionary functions

public extension JSON {
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) throws -> [String: T] {
        let dictionary: [String: AnyObject] = try cast(raw)
        var new = [String: T](minimumCapacity: dictionary.count)
        try dictionary.forEach {
            let value: T = try JSON($1).distil()
            new[$0] = value
        }
        return new
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
    
    func distil<T: Distillable>(path: JSONPath) -> [String: T].Type -> InsecureDistillate<[String: T]> {
        return { _ in InsecureDistillate { try self.distil(path)([String: T]) } }
    }
    
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return InsecureDistillate { try self.distil() }
    }
    
    func distil<T: Distillable>(path: JSONPath) -> InsecureDistillate<[String: T]> {
        return distil(path)([String: T])
    }
}

// MARK: - distil option dictionary functions

public extension JSON {
    func option<T: Distillable>(path: JSONPath) -> Optional<[String: T]>.Type throws -> Optional<[String: T]> {
        return { _ in
            do {
                return try self.distil(path)([String: T])
            } catch let DistillError.MissingPath(missing) where missing == path {
                return nil
            }
        }
    }
    
    func option<T: Distillable>(path: JSONPath) throws -> Optional<[String: T]> {
        return try option(path)(Optional<[String: T]>)
    }
    
    func option<T: Distillable>(path: JSONPath) -> Optional<[String: T]>.Type -> InsecureDistillate<Optional<[String: T]>> {
        return { _ in InsecureDistillate { try self.option(path) } }
    }
    
    func option<T: Distillable>(path: JSONPath) -> InsecureDistillate<Optional<[String: T]>> {
        return option(path)(Optional<[String: T]>)
    }
}

// MARK: - serialize value functions

public extension JSON {
    static func serializeToData(serializable: Serializable, options: NSJSONWritingOptions = []) -> NSData {
        return serializeToData(serializable.serialize().object, options: options)
    }
    
    static func serializeToData(serializable: Serializable, rootKey: String, options: NSJSONWritingOptions = []) -> NSData {
        return serializeToData([rootKey: serializable.serialize().object], options: options)
    }
    
    static func serializeToString(serializable: Serializable, options: NSJSONWritingOptions = []) -> String {
        return String(data: serializeToData(serializable, options: options), encoding: NSUTF8StringEncoding)!
    }
    
    static func serializeToString(serializable: Serializable, rootKey: String, options: NSJSONWritingOptions = []) -> String {
        return String(data: serializeToData(serializable, rootKey: rootKey, options: options), encoding: NSUTF8StringEncoding)!
    }
}

// MARK: - serialize array functions

public extension JSON {
    static func serializeToData<T: Serializable>(serializables: [T], options: NSJSONWritingOptions = []) -> NSData {
        return serializeToData(serializables.map { $0.serialize().object }, options: options)
    }
    
    static func serializeToData<T: Serializable>(serializables: [T], rootKey: String, options: NSJSONWritingOptions = []) -> NSData {
        return serializeToData([rootKey: serializables.map { $0.serialize().object }], options: options)
    }
    
    static func serializeToString<T: Serializable>(serializable: [T], options: NSJSONWritingOptions = []) -> String {
        return String(data: serializeToData(serializable, options: options), encoding: NSUTF8StringEncoding)!
    }
    
    static func serializeToString<T: Serializable>(serializable: [T], rootKey: String, options: NSJSONWritingOptions = []) -> String {
        return String(data: serializeToData(serializable, rootKey: rootKey, options: options), encoding: NSUTF8StringEncoding)!
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
    func distilRecursive<T>(path: JSONPath) throws -> T {
        func distilRecursive(object: AnyObject, _ paths: ArraySlice<JSONPathElement>) throws -> AnyObject {
            switch paths.first {
            case let .Key(key)?:
                let dictionary: [String: AnyObject] = try cast(object)
                
                guard let value = dictionary[key] where !(value is NSNull) else {
                    throw DistillError.MissingPath(path)
                }
                
                return try distilRecursive(value, paths.dropFirst())
                
            case let .Index(index)?:
                let array: [AnyObject] = try cast(object)
                
                guard array.count > index else {
                    throw DistillError.MissingPath(path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw DistillError.MissingPath(path)
                }
                
                return try distilRecursive(value, paths.dropFirst())
                
            case .None:
                return object
            }
        }
        
        return try cast(distilRecursive(raw, ArraySlice(path.paths)))
    }
    
    func cast<T>(object: AnyObject) throws -> T {
        guard let value = object as? T else {
            throw DistillError.TypeMismatch(expected: T.self, actual: object)
        }
        return value
    }
    
    static func serializeToData(object: AnyObject, options: NSJSONWritingOptions = []) -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(object, options: options)
    }
}
