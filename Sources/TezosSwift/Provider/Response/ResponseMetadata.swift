
import Foundation

struct ResponseMetadata {
    let operation_result: OperationResult
    let balance_updates:[OperationResultBalanceUpdates]?
    let internal_operation_results: [InternalOperationResult]?
}

extension ResponseMetadata: Decodable {
    private enum CodingKeys: String, CodingKey {
        case operation_result
        case balance_updates
        case internal_operation_results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operation_result = try container.decode(OperationResult.self, forKey: .operation_result)
        self.balance_updates = try container.decodeIfPresent([OperationResultBalanceUpdates].self, forKey:.balance_updates ) ?? []
        self.internal_operation_results = try container.decodeIfPresent([InternalOperationResult].self, forKey: .internal_operation_results) ?? []
    }
}
