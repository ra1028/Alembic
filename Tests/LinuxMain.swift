#if os(Linux)

import XCTest
@testable import AlembicTests

XCTMain([
    testCase(DistilTest.allTests),
    testCase(OptionalTest.allTests),
    testCase(TransformTest.allTests),
    testCase(SerializeTest.allTests),
])

#endif
