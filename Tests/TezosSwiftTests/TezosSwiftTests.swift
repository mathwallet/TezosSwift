import XCTest
import CryptoSwift

@testable import TezosSwift


final class TezosSwiftTests: XCTestCase {
    func testKeyPairExample() throws {
        let keypair = try TezosKeypair(mnemonics: "live yellow blind genuine online purse scare foot speak vanish resist tornado", path: "m/44'/1729'/0'/0'")
        XCTAssertEqual(keypair.privateKey, "edskS9ukoZnW2AYE6LiPv7PPi8xmybZm27jCWoYj1AmtfbBdZdeXbCGm7pGX9pF8kfiV2J2NysNWF93DpcdDmUPRSF7CTWf8DR")
        XCTAssertEqual(keypair.address.address, "tz1iHBXnb6TzUnCZs4UUxyYLgoB5G2yDyE6T")
    }
    
    func testSignAndVerifyExample() throws {
        let keypair = try TezosKeypair(mnemonics: "live yellow blind genuine online purse scare foot speak vanish resist tornado", path: "m/44'/1729'/0'/0'")
        
        let message = "message".data(using: .utf8)!
        let messageDigest = try message.genericHash(outputLength: 32)
        
        let signature = try keypair.signDigest(messageDigest: messageDigest)
        
        XCTAssertTrue(keypair.signVerify(messageDigest: messageDigest, signature: signature))
    }
}
