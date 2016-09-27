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
    public let currentPath = Path.empty
    
    public subscript(element: PathElement) -> LazyJSON {
        return .init(json: self, path: .init(element: element))
    }
    
    public subscript(element: PathElement...) -> LazyJSON {
        return .init(json: self, path: .init(elements: element))
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
    public func distil<T: Distillable>(_ path: Path, to: T.Type) throws -> T {
        do {
            let object: Any = try distilRecursive(raw, path)
            return try .distil(json: JSON(object))
        } catch let DistillError.missingPath(missing) where path != missing {
            throw DistillError.missingPath(path + missing)
        }
    }
    
    public func distil<T: Distillable>(_ path: Path, to: [T].Type) throws -> [T] {
        let object: Any = try distilRecursive(raw, path)
        return try .distil(json: JSON(object))
    }
    
    public func distil<T: Distillable>(_ path: Path, to: [String: T].Type) throws -> [String: T] {
        let object: Any = try distilRecursive(raw, path)
        return try .distil(json: JSON(object))
    }
}

// MARK: - JSONType

extension JSON: JSONType {
    public func asJSON() -> JSON {
        return self
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

private func distilRecursive<T>(_ raw: Any, _ path: Path) throws -> T {
    func distilRecursive(_ object: Any, _ elements: ArraySlice<PathElement>) throws -> Any {
        switch elements.first {
        case let .key(key)?:
            let dictionary: [String: Any] = try cast(object)
            
            guard let value = dictionary[key], !(value is NSNull) else {
                throw DistillError.missingPath(path)
            }
            
            return try distilRecursive(value, elements.dropFirst())
            
        case let .index(index)?:
            let array: [Any] = try cast(object)
            
            guard array.count > index else {
                throw DistillError.missingPath(path)
            }
            
            let value = array[index]
            
            if value is NSNull {
                throw DistillError.missingPath(path)
            }
            
            return try distilRecursive(value, elements.dropFirst())
            
        case .none:
            return object
        }
    }
    
    return try cast(distilRecursive(raw, ArraySlice(path.elements)))
}

private func cast<T>(_ object: Any) throws -> T {
    guard let value = object as? T else {
        throw DistillError.typeMismatch(expected: T.self, actual: object)
    }
    return value
}
