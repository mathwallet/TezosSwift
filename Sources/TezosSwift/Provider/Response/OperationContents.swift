

import Foundation

public struct OperationContents:Decodable {
    let contents: [OperationStatus]?
    let signature: String
}
