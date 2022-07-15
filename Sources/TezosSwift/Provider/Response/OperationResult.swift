

import Foundation

enum OperationResultStatus:Codable {
    case failed
    case backtracked
    case skipped
    case success
    case applied
    case unknow
    
    static func get(status: String?) -> OperationResultStatus {
        let found = status == "failed"
        return found ? .failed : .unknow
    }
}

struct InternalOperationResult: Decodable {
    let kind:String
    let source:String
    let nonce:Int
    let amount:String
    let destination:String
    let result: OperationResult?
}

struct OperationResult:Decodable {
    var status:String
    var balance_updates:[OperationResultBalanceUpdates]?
    var consumed_gas:String
    var consumed_milligas:String
    var allocated_destination_contract:[String:String]?
    var paid_storage_size_diff:String?
}

public struct OperationResultBalanceUpdates:Decodable {
    var kind:String?
    var contract:String?
    var change:String?
    var origin:String?
}

