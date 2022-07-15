import XCTest

@testable import TezosSwift


final class TezosSwiftTests: XCTestCase {
    func testExample() throws {
        let keypair = try TezosKeypair(mnemonics: "live yellow blind genuine online purse scare foot speak vanish resist tornado", path: "m/44'/1729'/0'/0'")
        XCTAssertEqual(keypair.privateKey, "edskS9ukoZnW2AYE6LiPv7PPi8xmybZm27jCWoYj1AmtfbBdZdeXbCGm7pGX9pF8kfiV2J2NysNWF93DpcdDmUPRSF7CTWf8DR")
        XCTAssertEqual(keypair.address.address, "tz1iHBXnb6TzUnCZs4UUxyYLgoB5G2yDyE6T")
    }
}
