//
//  LinuxMain.swift
//  Alembic
//
//  Created by Ryo Aoyama on 9/28/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//
#if os(Linux)

import XCTest
@testable import AlembicTests

XCTMain([
    testCase(DistilTest.allTests),
    testCase(OptionalTest.allTests),
    testCase(TransformTest.allTests),
])

#endif
