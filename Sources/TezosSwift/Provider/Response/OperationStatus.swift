
import Foundation

struct OperationStatus:Decodable {
    let kind:String
    let source:String
    let fee:String
    let counter:String
    let gas_limit:String
    let storage_limit:String
    let amount:String
    let destination:String
    let metadata: ResponseMetadata?
}
