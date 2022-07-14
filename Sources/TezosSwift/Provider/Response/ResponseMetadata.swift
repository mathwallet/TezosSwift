
import Foundation

struct ResponseMetadata:Codable {
    let operationResult: OperationResult?
    let internalOperationResults: [InternalOperationResult]?
}

extension ResponseMetadata {
    private enum CodingKeys: String, CodingKey {
        case operationResult = "operation_result"
        case internalOperationResults = "internal_operation_results"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operationResult = try container.decode(OperationResult.self, forKey: .operationResult)
        self.internalOperationResults = try container.decodeIfPresent([InternalOperationResult].self, forKey: .internalOperationResults) ?? []
    }
}
