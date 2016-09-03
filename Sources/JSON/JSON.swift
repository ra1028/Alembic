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
    
    public subscript(path: PathElement) -> LazyJSON {
        return .init(self, Path(path))
    }
    
    public subscript(path: PathElement...) -> LazyJSON {
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

// MARK: - distil functions

public extension JSON {
    func distil<T: Distillable>(_ path: Path, to: T.Type = T.self) throws -> T {
        do {
            let object: Any = try distilRecursive(path)
            return try .distil(JSON(object))
        } catch let DistillError.missingPath(missing) where path != missing {
            throw DistillError.missingPath(path + missing)
        }
    }
    
    func distil<T: Distillable>(_ path: Path, to: [T].Type = [T].self) throws -> [T] {
        let arr: [Any] = try distilRecursive(path)
        return try arr.map { try JSON($0).distil() }
    }
    
    func distil<T: Distillable>(_ path: Path, to: [String: T].Type = [String: T].self) throws -> [String: T] {
        let dic: [String: Any] = try distilRecursive(path)
        var new = [String: T](minimumCapacity: dic.count)
        try dic.forEach { try new.updateValue(JSON($1).distil(), forKey: $0) }
        return new
    }
}

// MARK: - lazy distil functions

public extension JSON {
    func distil<T: Distillable>(_ path: Path, to: T.Type = T.self) -> InsecureDistillate<T> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path, to: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path, to: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try self.distil(path) }
    }
}

// MARK: - distil option functions

public extension JSON {
    func option<T: Distillable>(_ path: Path, to: T?.Type = (T?).self) throws -> T? {
        return try option(path) { try distil($0, to: T.self) }
    }
    
    func option<T: Distillable>(_ path: Path, to: [T]?.Type = ([T]?).self) throws -> [T]? {
        return try option(path) { try distil($0, to: [T].self) }
    }
    
    func option<T: Distillable>(_ path: Path, to: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        return try option(path) { try distil($0, to: [String: T].self) }
    }
}

// MARK: - distil option functions

public extension JSON {
    func option<T: Distillable>(_ path: Path, to: T?.Type = (T?).self) -> InsecureDistillate<T?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path, to: [T]?.Type = ([T]?).self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path, to: [String: T]?.Type = ([String: T]?).self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(path) }
    }
}

// MARK: - JSONType

extension JSON: JSONType {}

public extension JSON {
    func distil<T: Distillable>(to: T.Type = T.self) throws -> T {
        return try distil([])
    }
    
    func distil<T: Distillable>(to: [T].Type = [T].self) throws -> [T] {
        return try distil([])
    }
    
    func distil<T: Distillable>(to: [String: T].Type = [String: T].self) throws -> [String: T] {
        return try distil([])
    }
}

public extension JSON {
    func option<T: Distillable>(to: T?.Type = (T?).self) throws -> T? {
        return try option([])
    }
    
    func option<T: Distillable>(to: [T]?.Type = ([T]?).self) throws -> [T]? {
        return try option([])
    }
    
    func option<T: Distillable>(to: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        return try option([])
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
    
    func option<T>(_ path: Path, distil: (Path) throws -> T) throws -> T? {
        do {
            return try distil(path)
        } catch let DistillError.missingPath(missing) where missing == path {
            return nil
        }
    }
}
