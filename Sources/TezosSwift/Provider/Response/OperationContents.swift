

import Foundation

public struct OperationContents {
    let contents: [OperationStatus]
    let signature: String
}

extension OperationContents: Decodable {
    private enum CodingKeys: String, CodingKey {
        case contents
        case signature
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contents = try container.decodeIfPresent([OperationStatus].self, forKey: .contents) ?? []
        self.signature = try container.decode(String.self, forKey: .signature)
    }
}
