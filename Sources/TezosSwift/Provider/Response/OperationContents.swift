

import Foundation

public struct OperationContents:Codable {
    let contents: [OperationStatus]?
    let signature: String?
    private enum CodingKeys: String, CodingKey {
        case contents
        case signature
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contents = try container.decode([OperationStatus].self, forKey: .contents)
        self.signature = try container.decode(String.self, forKey: .contents)
    }
}
