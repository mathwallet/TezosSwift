

import Foundation

public struct OperationContents: Decodable {
    let contents: [OperationStatus]?
    let signature: String
}

public struct MergedOperationResult: Decodable {
    let fee: String?
    let operation_result: OperationResult
}
