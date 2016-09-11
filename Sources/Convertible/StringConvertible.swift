//
//  StringConvertible.swift
//  Alembic
//
//  Created by Ryo Aoyama on 9/11/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public protocol StringConvertible {
    var stringValue: String { get }
}

extension String: StringConvertible {
    public var stringValue: String {
        return self
    }
}
