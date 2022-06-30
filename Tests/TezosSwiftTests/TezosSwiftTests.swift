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
    }
    
    func testSign() throws {
//        let messageData = Data(hex:"68a96f2e334508f274420c7d2b9217ec50565f52cd5e7d7c1c92541f0fb7427b6c001529f76d60c0e446c1ab948f19e4bd3e125fb42bcd04a695d5199d0e8102a08d0600008724ba8bc695a710601279c31c2acbe4ede5c03000" )
        
        let messageData = Sodium().utils.hex2bin("68a96f2e334508f274420c7d2b9217ec50565f52cd5e7d7c1c92541f0fb7427b6c001529f76d60c0e446c1ab948f19e4bd3e125fb42bcd04a695d5199d0e8102a08d0600008724ba8bc695a710601279c31c2acbe4ede5c03000")!
        let watermarkedOperation = [3]+messageData
        let prepareData = Sodium().genericHash.hash(message: watermarkedOperation, outputLength: 32)!
        let privateData = Data(hex: "062564b4f072614455d1e410b1916ffbe7c91a752bd3b1cb1b296d1ac0330eff1a9ae95454c4a255d482a4555c792798c841f40042eb04ae16f2714b56f11680")
        let sss = Sodium().sign.signature(message: prepareData, secretKey: privateData.bytes)?.toHexString()
//        let keypair = try! Ed25519KeyPair(raw: )
//        let signedString = try! keypair.sign(message:messageData).raw.toHexString()
        print(sss)
        
    }
}
