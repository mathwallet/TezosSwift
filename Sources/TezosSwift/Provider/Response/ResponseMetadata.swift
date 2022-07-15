
import Foundation

struct ResponseMetadata:Codable {
    var operation_result: OperationResult?
    var internal_operation_results: [InternalOperationResult]?
}
