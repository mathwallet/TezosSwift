import XCTest
import CryptoSwift
import Ed25519
import Sodium
@testable import TezosSwift


final class TezosSwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let pa = TezosOperationUtil.fa2Parameters(from: "from", to: "to", amount: "amount", tokenId: "tokenid")
        let data = try! JSONEncoder().encode(pa)
        print(String(data: data, encoding: .utf8))
    }
}
