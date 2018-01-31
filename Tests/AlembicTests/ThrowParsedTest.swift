import Foundation
import XCTest
@testable import Alembic

final class ThrowParsedTest: XCTestCase {
    func testInitialize() {
        enum Error: Swift.Error {
            case test
        }
        
        let valueParsed = ThrowParsed.value("value")
        XCTAssertEqual(try? valueParsed.value(), "value")
        
        let errorParsed = ThrowParsed<String>.error(Error.test)
        do {
            _ = try errorParsed.value()
            XCTFail("Expect to throw error")
        } catch {
            if case Error.test = error {} else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testTransform() {
        enum Error: Swift.Error  {
            case a, b
        }
        
        let parsed = ThrowParsed.value("Parsed")
        let errorParsed = ThrowParsed<String>.error(Error.a)
        
        let map = parsed.map { $0 + "-map" }
        XCTAssertEqual(try? map.value(), "Parsed-map")
        
        let ParsedFlatMap = parsed.flatMap { Parsed.value($0 + "-ParsedFlatMap") }
        XCTAssertEqual(try? ParsedFlatMap.value(), "Parsed-ParsedFlatMap")
        
        let throwParsedFlatMap = parsed.flatMap { ThrowParsed.value($0 + "-throwParsedFlatMap") }
        XCTAssertEqual(try? throwParsedFlatMap.value(), "Parsed-throwParsedFlatMap")
        
        let optionalFlatMap = parsed.filterMap { $0 + "-filterMap" as String? }
        XCTAssertEqual(try? optionalFlatMap.value(), "Parsed-filterMap")
        
        let filter = parsed.filter { !$0.isEmpty }
        XCTAssertEqual(try? filter.value(), "Parsed")
        
        let filterNil = parsed.map { $0 as String? }.filterNil()
        XCTAssertEqual(try? filterNil.value(), "Parsed")
        
        let recover = errorParsed.recover { _ in "Parsed-recover" }
        XCTAssertEqual(recover.value(), "Parsed-recover")
        
        let recoverWith = errorParsed.recover(with: "Parsed-recoverWith")
        XCTAssertEqual(recoverWith.value(), "Parsed-recoverWith")
        
        let mapError = errorParsed.mapError { _ in Error.b }
        do {
            _ = try mapError.value()
        } catch {
            if case Error.b = error {} else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        let ParsedFlatMapError = errorParsed.flatMapError { _ in Parsed.value("Parsed-ParsedFlatMapError") }
        XCTAssertEqual(ParsedFlatMapError.value(), "Parsed-ParsedFlatMapError")
        
        let throwParsedFlatMapError = errorParsed.flatMapError { _ in ThrowParsed.value("Parsed-throwParsedFlatMapError") }
        XCTAssertEqual(try? throwParsedFlatMapError.value(), "Parsed-throwParsedFlatMapError")
    }
}

extension ThrowParsedTest {
    static var allTests: [(String, (ThrowParsedTest) -> () throws -> Void)] {
        return [
            ("testInitialize", testInitialize),
            ("testTransform", testTransform)
        ]
    }
}
