//
//  JSONObject.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/15/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct JSONObject {
    let object: Any
    
    fileprivate init(object: Any) {
        self.object = object
    }
}

public extension JSONObject {
    init<T: JSONValueConvertible>(_ array: [T]) {
        object = array.map { $0.jsonValue.value }
    }
    
    init<T: JSONValueConvertible>(_ dictionary: [String: T]) {
        var new = [String: Any](minimumCapacity: dictionary.count)
        dictionary.forEach { new[$0] = $1.jsonValue.value }
        object = new
    }
    
    func toData(_ options: JSONSerialization.WritingOptions = []) -> Data {
        return JSON.serializeToData(self, options: options)
    }
    
    func toData(_ rootKey: String, options: JSONSerialization.WritingOptions = []) -> Data {
        return JSON.serializeToData(self, rootKey: rootKey, options: options)
    }
    
    func toString(_ options: JSONSerialization.WritingOptions = []) -> String {
        return JSON.serializeToString(self, options: options)
    }
    
    func toString(_ rootKey: String, options: JSONSerialization.WritingOptions = []) -> String {
        return JSON.serializeToString(self, rootKey: rootKey, options: options)
    }
}

extension JSONObject: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValueConvertible...) {
        let array = elements.map { $0.jsonValue.value }
        self.init(object: array)
    }
}

extension JSONObject: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValueConvertible)...) {
        var dictionary = [String: Any](minimumCapacity: elements.count)
        elements.forEach { dictionary[$0] = $1.jsonValue.value }
        self.init(object: dictionary)
    }
}
