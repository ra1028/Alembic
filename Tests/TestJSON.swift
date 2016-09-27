//
//  TestJSON.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

enum TestJSON {
    case distil
    case optional
    case transform
    case serialize
    
    var fileName: String {
        switch self {
        case .distil: return "DistilTests"
        case .optional: return "OptionalTests"
        case .transform: return "TransformTests"
        case .serialize: return "SerializeTests"
        }
    }
    
    var data: Data {
        return Bundle(for: DistilTests.self).url(forResource: fileName, withExtension: "json")
            .flatMap { try! Data.init(contentsOf: $0) }!
    }
    
    var string: String {
        return String(data: data, encoding: .utf8)!
    }
    
    var object: Any {
        return try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}
