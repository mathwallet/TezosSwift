

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

enum OperationResultStatusValue: String, Codable {
    case failed
    case applied
}

public enum OperationErrorKind: String, Codable {
    case temporary
    case branch
    case permanent
}

public struct PreapplyError: Codable {
    public let kind: OperationErrorKind
    public let id: String
}

struct InternalOperationResult: Codable {
    var kind:String?
    var source:String?
    var nonce:Int?
    var amount:String?
    var destination:String?
    let result: InternalOperationResultStatus?
}

struct InternalOperationResultStatus: Codable {
    var status:String?
    var balance_updates:[OperationResultBalanceUpdates]?
    var consumed_gas:String?
    var consumed_milligas:String?
    var allocated_destination_contract:[String:String]?
    var paid_storage_size_diff:String?
}

struct OperationResult:Codable {
    var status:String?
    var balance_updates:[OperationResultBalanceUpdates]?
    var consumed_gas:String?
    var consumed_milligas:String?
    var allocated_destination_contract:[String:String]?
    var paid_storage_size_diff:String?
}

public struct OperationResultBalanceUpdates:Codable {
    var kind:String?
    var contract:String?
    var change:String?
    var origin:String?
}

