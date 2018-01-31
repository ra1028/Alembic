import Foundation
import XCTest
@testable import Alembic

final class ThrowParserTest: XCTestCase {
    func testInitialize() {
        enum Error: Swift.Error {
            case test
        }
        
        let valueParser = ThrowParser.value("value")
        XCTAssertEqual(try? valueParser.value(), "value")
        
        let errorParser = ThrowParser<String>.error(Error.test)
        do {
            _ = try errorParser.value()
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
        
        let parser = ThrowParser.value("value")
        let errorParser = ThrowParser<String>.error(Error.a)
        
        let map = parser.map { $0 + "-map" }
        XCTAssertEqual(try? map.value(), "value-map")
        
        let ParserFlatMap = parser.flatMap { Parser.value($0 + "-flatMap") }
        XCTAssertEqual(try? ParserFlatMap.value(), "value-flatMap")
        
        let throwParserFlatMap = parser.flatMap { ThrowParser.value($0 + "-throwFlatMap") }
        XCTAssertEqual(try? throwParserFlatMap.value(), "value-throwFlatMap")
        
        let optionalFlatMap = parser.filterMap { $0 + "-filterMap" as String? }
        XCTAssertEqual(try? optionalFlatMap.value(), "value-filterMap")
        
        let filter = parser.filter { !$0.isEmpty }
        XCTAssertEqual(try? filter.value(), "value")
        
        let filterNil = parser.map { $0 as String? }.filterNil()
        XCTAssertEqual(try? filterNil.value(), "value")
        
        let recover = errorParser.recover { _ in "recover" }
        XCTAssertEqual(recover.value(), "recover")
        
        let recoverWith = errorParser.recover(with: "recoverWith")
        XCTAssertEqual(recoverWith.value(), "recoverWith")
        
        let mapError = errorParser.mapError { _ in Error.b }
        do {
            _ = try mapError.value()
        } catch {
            if case Error.b = error {} else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        let ParserFlatMapError = errorParser.flatMapError { _ in Parser.value("flatMapError") }
        XCTAssertEqual(ParserFlatMapError.value(), "flatMapError")
        
        let throwParserFlatMapError = errorParser.flatMapError { _ in ThrowParser.value("throwFlatMapError") }
        XCTAssertEqual(try? throwParserFlatMapError.value(), "throwFlatMapError")
    }
}

extension ThrowParserTest {
    static var allTests: [(String, (ThrowParserTest) -> () throws -> Void)] {
        return [
            ("testInitialize", testInitialize),
            ("testTransform", testTransform)
        ]
    }
}
