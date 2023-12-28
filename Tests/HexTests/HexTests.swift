import Hex
import XCTest

final class HexStringTests: XCTestCase {
    private let bytes: [UInt8] = [0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]
    private let lowercaseExpected = "0123456789abcdef"
    private let uppercaseExpected = "0123456789ABCDEF"
    
    func testDecoding() {
        XCTAssertEqual(Array(hexEncoded: lowercaseExpected), bytes)
        XCTAssertEqual(Array(hexEncoded: uppercaseExpected), bytes)
        XCTAssertNil(Array(hexEncoded: "01 23456789abcdef"))
        XCTAssertNil(Array(hexEncoded: "0x0123456789abcdef"))
        XCTAssertNil(Array(hexEncoded: "01:23:45:67:89:ab:cd:ef"))
    }
    
    func testArrayEncoding() {
        XCTAssert(bytes.hexEncodedBytes().elementsEqual(lowercaseExpected.utf8))
        XCTAssert(bytes.hexEncodedBytes(uppercase: true).elementsEqual(uppercaseExpected.utf8))
        XCTAssertEqual(bytes.hexEncodedString(), lowercaseExpected)
        XCTAssertEqual(bytes.hexEncodedString(uppercase: true), uppercaseExpected)
    }
    
    func testRandomRoundtrips() {
        for count in 0..<512 {
            let bytes = Array.random(ofCount: count)
            XCTAssertEqual(Array(hexEncoded: bytes.hexEncodedBytes()), bytes)
            XCTAssertEqual(Array(hexEncoded: bytes.hexEncodedString()), bytes)
        }
    }
    
    func testHexEncodedString() throws {
        struct Struct: Codable {
            @HexEncodedString var bytes: [UInt8]
        }
        let encoded = Data(#"{"bytes":"\#(lowercaseExpected)"}"#.utf8)
        let decoded = try JSONDecoder().decode(Struct.self, from: encoded)
        XCTAssertEqual(decoded.bytes, bytes)
        XCTAssertEqual(try JSONEncoder().encode(decoded), encoded)
    }
}

extension Array<UInt8> {
    fileprivate static func random(ofCount count: Int) -> Self {
        var rng = SystemRandomNumberGenerator()
        return (0..<count).map({ _ in rng.next() })
    }
}
