#if os(Linux)

import XCTest
@testable import AlembicTests

XCTMain([
    testCase(JSONTest.allTests),
    testCase(ValueTest.allTests),
    testCase(OptionTest.allTests),
    testCase(DecodeTest.allTests),
    testCase(DecodedTest.allTests),
    testCase(ThrowDecodedTest.allTests),
    testCase(PathTest.allTests),
    testCase(ErrorTest.allTests)
])

#endif
