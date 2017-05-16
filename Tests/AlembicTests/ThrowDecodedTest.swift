import Foundation
import XCTest
@testable import Alembic

final class ThrowDecodedTest: XCTestCase {
    func testInitialize() {
        enum Error: Swift.Error {
            case test
        }
        
        let valueDecoded = ThrowDecoded.value("value")
        XCTAssertEqual(try? valueDecoded.value(), "value")
        
        let errorDecoded = ThrowDecoded<String>.error(Error.test)
        do {
            _ = try errorDecoded.value()
            XCTFail("Expect to throw error")
        } catch let error {
            if case Error.test = error {} else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testTransform() {
        enum Error: Swift.Error  {
            case a, b
        }
        
        let decoded = ThrowDecoded.value("decoded")
        let errorDecoded = ThrowDecoded<String>.error(Error.a)
        
        let map = decoded.map { $0 + "-map" }
        XCTAssertEqual(try? map.value(), "decoded-map")
        
        let decodedFlatMap = decoded.flatMap { Decoded.value($0 + "-decodedFlatMap") }
        XCTAssertEqual(try? decodedFlatMap.value(), "decoded-decodedFlatMap")
        
        let throwDecodedFlatMap = decoded.flatMap { ThrowDecoded.value($0 + "-throwDecodedFlatMap") }
        XCTAssertEqual(try? throwDecodedFlatMap.value(), "decoded-throwDecodedFlatMap")
        
        let optionalFlatMap = decoded.flatMap { $0 + "-optionalFlatMap" as String? }
        XCTAssertEqual(try? optionalFlatMap.value(), "decoded-optionalFlatMap")
        
        let filter = decoded.filter { !$0.isEmpty }
        XCTAssertEqual(try? filter.value(), "decoded")
        
        let filterNil = decoded.map { $0 as String? }.filterNil()
        XCTAssertEqual(try? filterNil.value(), "decoded")
        
        let recover = errorDecoded.recover { _ in "decoded-recover" }
        XCTAssertEqual(recover.value(), "decoded-recover")
        
        let recoverWith = errorDecoded.recover(with: "decoded-recoverWith")
        XCTAssertEqual(recoverWith.value(), "decoded-recoverWith")
        
        let mapError = errorDecoded.mapError { _ in Error.b }
        do {
            _ = try mapError.value()
        } catch let error {
            if case Error.b = error {} else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        let decodedFlatMapError = errorDecoded.flatMapError { _ in Decoded.value("decoded-decodedFlatMapError") }
        XCTAssertEqual(decodedFlatMapError.value(), "decoded-decodedFlatMapError")
        
        let throwDecodedFlatMapError = errorDecoded.flatMapError { _ in ThrowDecoded.value("decoded-throwDecodedFlatMapError") }
        XCTAssertEqual(try? throwDecodedFlatMapError.value(), "decoded-throwDecodedFlatMapError")
    }
}

extension ThrowDecodedTest {
    static var allTests: [(String, (ThrowDecodedTest) -> () throws -> Void)] {
        return [
            ("testInitialize", testInitialize),
            ("testTransform", testTransform)
        ]
    }
}
