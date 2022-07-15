
import Foundation

struct ResponseMetadata:Decodable {
    var operation_result: OperationResult?
    var balance_updates:[OperationResultBalanceUpdates]?
    var internal_operation_results: [InternalOperationResult]?
}
