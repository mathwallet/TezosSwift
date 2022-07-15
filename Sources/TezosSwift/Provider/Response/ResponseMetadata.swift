
import Foundation

struct ResponseMetadata {
    let operation_result: OperationResult
    let balance_updates:[OperationResultBalanceUpdates]?
    let internal_operation_results: [InternalOperationResult]?
}
