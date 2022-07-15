import XCTest
import CryptoSwift
import Ed25519

@testable import TezosSwift


final class TezosSwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let string="{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1MZwA2p5vqa5tZonbb3f3BZTBhUeXqfpUF\",\"fee\":\"0\",\"counter\":\"53824196\",\"gas_limit\":\"800000\",\"storage_limit\":\"60000\",\"amount\":\"10000\",\"destination\":\"tz1XxbuyFz7v7h4TaXPEY5gkndjk48s2Lid6\",\"metadata\":{\"operation_result\":{\"status\":\"applied\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1MZwA2p5vqa5tZonbb3f3BZTBhUeXqfpUF\",\"change\":\"-10000\",\"origin\":\"block\"},{\"kind\":\"contract\",\"contract\":\"tz1XxbuyFz7v7h4TaXPEY5gkndjk48s2Lid6\",\"change\":\"10000\",\"origin\":\"block\"}],\"consumed_gas\":\"1451\",\"consumed_milligas\":\"1450040\"}}}],\"signature\":\"edsigtkpiSSschcaCt9pUVrpNPf7TTcgvgDEDD6NCEHMy8NNQJCGnMfLZzYoQj74yLjo9wx6MPVV29CvVzgi7qEcEUok3k7AuMg\"}"
        let ss = string.data(using: .utf8)
        if let result = try? JSONDecoder().decode(OperationContents.self, from: ss!){
            print(result.signature ?? "")
        } else {
            print("")
        }
        
    }
}
