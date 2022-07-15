
import Foundation

struct ResponseMetadata:Codable {
    let operation_result: OperationResult?
    let internal_operation_results: [InternalOperationResult]?
}
