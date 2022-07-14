
import Foundation

struct OperationStatus:Codable {
    let counter: Int?
    let kind:String?
    let metadata: ResponseMetadata?
}

extension OperationStatus {
    private enum CodingKeys: String, CodingKey {
        case counter
        case metadata
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.counter = try container.decode(Int.self, forKey: .counter)
        self.kind = try container.decode(String.self, forKey: .counter)
        self.metadata = try container.decode(ResponseMetadata.self, forKey: .metadata)
    }
}
