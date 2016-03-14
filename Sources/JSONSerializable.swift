//
//  JSONSerializable.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/14/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public protocol JSONSerializable {
    func serialize() -> JSONObject
}