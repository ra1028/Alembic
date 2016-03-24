//
//  Serializable.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/14/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public protocol Serializable {
    func serialize() -> JSONObject
}

extension JSONObject: Serializable {
    public func serialize() -> JSONObject {
        return self
    }
}