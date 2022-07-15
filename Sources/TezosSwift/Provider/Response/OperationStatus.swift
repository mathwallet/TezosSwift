
import Foundation

struct OperationStatus:Decodable {
    var kind:String?
    var source:String?
    var fee:String?
    var counter:String?
    var gas_limit:String?
    var storage_limit:String?
    var amount:String?
    var destination:String?
    var metadata: ResponseMetadata?
}
