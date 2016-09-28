//
//  TestJSON.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

let distilTestJSONObject: [String: Any] = [
    "string": "Alembic",
    "int": 777,
    "double": 77.7,
    "float": 77.7 as Float,
    "bool": true,
    "array": [
        "A", "B", "C"
    ],
    "dictionary": [
        "A": 1, "B": 2, "C": 3
    ],
    "nested": [
        "array": [
            1, 2, 3, 4, 5
        ]
    ],
    "int_string": "1",
    "user": [
        "id": 100,
        "name": "ra1028",
        "weight": 132.28,
        "gender": "male",
        "smoker": true,
        "contact": [
            "email": "r.fe51028.r@gmail.com",
            "url": "https://github.com/ra1028"
        ],
        "friends": [
            [
                "id": 101,
                "name": "ABCDE",
                "weight": 120.00,
                "gender": "female",
                "smoker": false,
                "contact": [
                    "email": "abcde@example.com",
                    "url": "https://example"
                ],
                "friends": [[String: Any]]()
            ]
        ]
    ],
    "numbers": [
        "number": 1 as NSNumber,
        "int8": 2 as NSNumber,
        "uint8": 3 as NSNumber,
        "int16": 4 as NSNumber,
        "uint16": 5 as NSNumber,
        "int32": 6 as NSNumber,
        "uint32": 7 as NSNumber,
        "int64": 8 as NSNumber,
        "uint64": 9 as NSNumber
    ]
]

let optionalTestJSONObject: [String: Any] = [
    "string": "Alembic",
    "int": 777,
    "float": 77.7 as Float,
    "bool": NSNull(),
    "array": [
        "A", "B", "C"
    ],
    "dictionary": [
        "A": 1, "B": 2, "C": 3
    ],
    "nested": [String: Any](),
    "user2": [
        "id": 100,
        "name": "ra1028",
        "contact": [String: Any]()
    ]
]

let transformTestJSONObject: [String: Any] = [
    "key": "value",
    "null": NSNull(),
    "array": [String](),
    "nested": ["nested_key": "nested_value"]
]
