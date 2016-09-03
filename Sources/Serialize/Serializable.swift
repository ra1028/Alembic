//
//  Serializable.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/14/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
public protocol Serializable {
    func serialize() -> JSONObject
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONObject: Serializable {
    public func serialize() -> JSONObject {
        return self
    }
}