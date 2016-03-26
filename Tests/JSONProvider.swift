//
//  JSONProvider.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

class JSONProvider {
    static func data(file: String) -> NSData? {
        return NSBundle(forClass: JSONProvider.self).pathForResource(file, ofType: "json")
            .flatMap(NSData.init(contentsOfFile:))
    }
    
    static func object(file: String) -> AnyObject? {
        return data(file).flatMap {
            try? NSJSONSerialization.JSONObjectWithData($0, options: [])
        }
    }
}