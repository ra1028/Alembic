//
//  JSONObject.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/15/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct JSONObject {
    let object: AnyObject
    
    private init(object: AnyObject) {
        self.object = object
    }
}

public extension JSONObject {
    init<T: JSONValueConvertible>(_ array: [T]) {
        object = array.map { $0.jsonValue().value }
    }
    
    init<T: JSONValueConvertible>(_ dictionary: [String: T]) {
        object = dictionary.reduce([String: AnyObject]()) { (var new, old) in
            new[old.0] = old.1.jsonValue().value
            return new
        }
    }
}

extension JSONObject: ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSONValueConvertible...) {
        let array = elements.map { $0.jsonValue().value }
        self.init(object: array)
    }
}

extension JSONObject: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, JSONValueConvertible)...) {
        let dictionary = elements.reduce([String: AnyObject](minimumCapacity: elements.count)) { (var new, element) in
            new[element.0] = element.1.jsonValue().value
            return new
        }
        self.init(object: dictionary)
    }
}