

import Foundation

public struct OperationContents:Codable {
    let contents: [OperationStatus]?
    private enum CodingKeys: String, CodingKey {
        case contents
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contents = try container.decode([OperationStatus].self, forKey: .contents)
    }
}
