//
//  JSON.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import class Foundation.JSONSerialization
import class Foundation.NSNull
import struct Foundation.Data

public final class JSON {
    public let raw: Any
    fileprivate let heapPath: Path
    fileprivate let createObject: () throws -> Any
    
    public subscript(element: PathElement...) -> JSON {
        let path = Path(elements: element)
        return .init(raw: raw, heapPath: heapPath + path) {
            try self.distil(path, to: JSON.self).raw
        }
    }
    
    public convenience init(_ raw: Any) {
        self.init(raw: raw) { raw }
    }
    
    public convenience init(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) {
        self.init(raw: data) { try serialize(data: data, options: options) }
    }
    
    public convenience init(
        string: String,
        encoding: String.Encoding = .utf8,
        allowLossyConversion: Bool = false,
        options: JSONSerialization.ReadingOptions = .allowFragments) {
        self.init(raw: string) {
            guard let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
                throw DistillError.typeMismatch(expected: String.self, actual: string)
            }
            return try serialize(data: data, options: options)
        }
    }
    
    fileprivate convenience init(raw: Any, heapPath: Path) {
        self.init(raw: raw, heapPath: heapPath) { raw }
    }
    
    private init(raw: Any, heapPath: Path = [], createObject: @escaping () throws -> Any) {
        self.raw = raw
        self.heapPath = heapPath
        self.createObject = createObject
    }
}

// MARK: - distil functions with type constraints

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

// MARK: - distil functions

public extension JSON {
    func distil<T: Distillable>(_ path: Path = [], to: T.Type = T.self) throws -> T {
        let fullPath = heapPath + path
        let object: Any = try distilRecursive(path: path)
        do {
            return try .distil(json: .init(raw: object, heapPath: fullPath))
        } catch let DistillError.missingPath(missing) {
            throw DistillError.missingPath(fullPath + missing)
        }
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [T].Type = [T].self) throws -> [T] {
        let fullPath = heapPath + path
        let object: Any = try distilRecursive(path: path)
        return try .distil(json: .init(raw: object, heapPath: fullPath))
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [String: T].Type = [String: T].self) throws -> [String: T] {
        let fullPath = heapPath + path
        let object: Any = try distilRecursive(path: path)
        return try .distil(json: .init(raw: object, heapPath: fullPath))
    }
}

// MARK: - lazy distil functions

public extension JSON {
    func distil<T: Distillable>(_ path: Path = [], to: T.Type = T.self) -> InsecureDistillate<T> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try self.distil(path) }
    }
}

// MARK: - distil option functions

public extension JSON {
    func option<T: Distillable>(_ path: Path = [], to: T?.Type = (T?).self) throws -> T? {
        do {
            return try distil(path, to: T.self)
        } catch let DistillError.missingPath(missing) where missing == heapPath + path {
            return nil
        }
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [T]?.Type = ([T]?).self) throws -> [T]? {
        return try option(path).map([T].distil)
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        return try option(path).map([String: T].distil)
    }
}

// MARK: - lazy distil option functions

public extension JSON {
    func option<T: Distillable>(_ path: Path = [], to: T?.Type = (T?).self) -> InsecureDistillate<T?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [T]?.Type = ([T]?).self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [String: T]?.Type = ([String: T]?).self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(path) }
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
    func distilRecursive<T>(path: Path) throws -> T {
        func distilRecursive(object: Any, elements: ArraySlice<PathElement>) throws -> Any {
            switch elements.first {
            case let .key(key)?:
                let dictionary: [String: Any] = try cast(object)
                
                guard let value = dictionary[key], !(value is NSNull) else {
                    throw DistillError.missingPath(path)
                }
                
                return try distilRecursive(object: value, elements: elements.dropFirst())
                
            case let .index(index)?:
                let array: [Any] = try cast(object)
                
                guard array.count > index else {
                    throw DistillError.missingPath(path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw DistillError.missingPath(path)
                }
                
                return try distilRecursive(object: value, elements: elements.dropFirst())
                
            case .none:
                return object
            }
        }
        
        let object = try createObject()
        let elements = ArraySlice(path.elements)
        return try cast(distilRecursive(object: object, elements: elements))
    }
}

private func serialize(data: Data, options: JSONSerialization.ReadingOptions) throws -> Any {
    do {
        return try JSONSerialization.jsonObject(with: data, options: options)
    } catch {
        throw DistillError.typeMismatch(expected: Data.self, actual: data)
    }
}

private func cast<T>(_ object: Any) throws -> T {
    guard let value = object as? T else {
        throw DistillError.typeMismatch(expected: T.self, actual: object)
    }
    return value
}
