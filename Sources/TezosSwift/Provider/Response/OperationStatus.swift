
import Foundation

struct OperationStatus:Codable {
    let kind:String?
    let source:String?
    let fee:String?
    let counter:String?
    let gas_limit:String?
    let storage_limit:String?
    let amount:String?
    let destination:String?
    let metadata: ResponseMetadata?
}

//extension OperationStatus {
//    private enum CodingKeys: String, CodingKey {
//        case counter
//        case metadata
//        case
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.kind = try container.decode(String.self, forKey: .counter)
//        self.source = try container.decode(String.self, forKey: .counter)
//        self.fee = try container.decode(String.self, forKey: .counter)
//        self.counter = try container.decode(String.self, forKey: .counter)
//        self.gas_limit = try container.decode(String.self, forKey: .counter)
//        self.storage_limit = try container.decode(String.self, forKey: .counter)
//        self.amount = try container.decode(String.self, forKey: .counter)
//        self.destination = try container.decode(String.self, forKey: .counter)
//        self.metadata = try container.decode(ResponseMetadata.self, forKey: .metadata)
//    }
//}
