
import Foundation

struct ResponseMetadata:Decodable {
    let operation_result: OperationResult
    let balance_updates:[OperationResultBalanceUpdates]?
    let internal_operation_results: [InternalOperationResult]?
}
