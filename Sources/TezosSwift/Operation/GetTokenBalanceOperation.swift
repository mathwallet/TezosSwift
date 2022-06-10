//
//  File.swift
//  
//
//  Created by 薛跃杰 on 2022/6/10.
//

import Foundation

let BALANCE_VALUE_MICHELINE = #"[{"prim":"PUSH","args":[{"prim":"mutez"},{"int":"0"}]},{"prim":"NONE","args":[{"prim":"key_hash"}]},{"prim":"CREATE_CONTRACT","args":[[{"prim":"parameter","args":[{"prim":"nat"}]},{"prim":"storage","args":[{"prim":"unit"}]},{"prim":"code","args":[[{"prim":"FAILWITH"}]]}]]},{"prim":"DIP","args":[[{"prim":"DIP","args":[[{"prim":"LAMBDA","args":[{"prim":"pair","args":[{"prim":"address"},{"prim":"unit"}]},{"prim":"pair","args":[{"prim":"list","args":[{"prim":"operation"}]},{"prim":"unit"}]},[{"prim":"CAR"},{"prim":"CONTRACT","args":[{"prim":"nat"}]},{"prim":"IF_NONE","args":[[{"prim":"PUSH","args":[{"prim":"string"},{"string":"a"}]},{"prim":"FAILWITH"}],[]]},{"prim":"PUSH","args":[{"prim":"address"},{"string":"%@"}]},{"prim":"PAIR"},{"prim":"DIP","args":[[{"prim":"PUSH","args":[{"prim":"address"},{"string":"%@"}]},{"prim":"CONTRACT","args":[{"prim":"pair","args":[{"prim":"address"},{"prim":"contract","args":[{"prim":"nat"}]}]}],"annots":["%%getBalance"]},{"prim":"IF_NONE","args":[[{"prim":"PUSH","args":[{"prim":"string"},{"string":"b"}]},{"prim":"FAILWITH"}],[]]},{"prim":"PUSH","args":[{"prim":"mutez"},{"int":"0"}]}]]},{"prim":"TRANSFER_TOKENS"},{"prim":"DIP","args":[[{"prim":"NIL","args":[{"prim":"operation"}]}]]},{"prim":"CONS"},{"prim":"DIP","args":[[{"prim":"UNIT"}]]},{"prim":"PAIR"}]]}]]},{"prim":"APPLY"},{"prim":"DIP","args":[[{"prim":"PUSH","args":[{"prim":"address"},{"string":"%@"}]},{"prim":"CONTRACT","args":[{"prim":"lambda","args":[{"prim":"unit"},{"prim":"pair","args":[{"prim":"list","args":[{"prim":"operation"}]},{"prim":"unit"}]}]}]},{"prim":"IF_NONE","args":[[{"prim":"PUSH","args":[{"prim":"string"},{"string":"c"}]},{"prim":"FAILWITH"}],[]]},{"prim":"PUSH","args":[{"prim":"mutez"},{"int":"0"}]}]]},{"prim":"TRANSFER_TOKENS"},{"prim":"DIP","args":[[{"prim":"NIL","args":[{"prim":"operation"}]}]]},{"prim":"CONS"}]]},{"prim":"CONS"},{"prim":"DIP","args":[[{"prim":"UNIT"}]]},{"prim":"PAIR"}]"#
let BALANCE_VIEW_CONTRACT_MAINNET = "KT1CPuTzwC7h7uLXd5WQmpMFso1HxrLBUtpE"

public struct GetTokenBalanceOperation:BaseOperation {
    var contents:[GetTokenBalanceOperationContent]
    var signature:String
    var branch:String
    
    init(
        address:String,
        tokenContractAddress:String,
        counter:String,
        branch:String
    ) {
        self.contents = [GetTokenBalanceOperationContent(address: address, tokenContractAddress: tokenContractAddress,counter:counter)]
        self.signature = "edsigtXomBKi5CTRf5cjATJWSyaRvhfYNHqSUGrn4SdbYRcGwQrUGjzEfQDTuqHhuA8b2d8NarZjz8TRf65WkpQmo423BtomS8Q"
        self.branch = branch
    }
    
    func toJsonString() -> String{
        do {
            let jsonData = try JSONEncoder().encode(self)
            let dataString = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "\"[", with: "[").replacingOccurrences(of: "]\"", with: "]").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
            guard let jsonString = dataString else {
                return ""
            }
            return jsonString
        }catch {
            return ""
        }
    }
    
    func toJsonDic() -> Dictionary<String, Any>? {
        let jsonData:Data = self.toJsonString().data(using: .utf8)!
        guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
            return nil
        }
       return dictionary
    }
}

public struct GetTokenBalanceOperationContent:Codable {
    
    var amount:String
    var storage_limit:String
    var gas_limit:String
    var kind:String
    var fee:String
    var destination:String
    var source:String
    var counter:String
    var parameters:GetTokenBalanceOperationContentParameters
    
    init(address:String,
        tokenContractAddress:String,
        counter:String) {
        self.amount = "0"
        self.storage_limit = "60000"
        self.gas_limit = "800000"
        self.kind = "transaction"
        self.fee = "0"
        self.destination = BALANCE_VIEW_CONTRACT_MAINNET
        self.source = address
        self.counter = counter
        self.parameters = GetTokenBalanceOperationContentParameters(address: address, tokenContractAddress: tokenContractAddress)
    }
}

public struct GetTokenBalanceOperationContentParameters:Codable {
    init(address:String,tokenContractAddress:String) {
        self.value = String(format: BALANCE_VALUE_MICHELINE, address,tokenContractAddress,BALANCE_VIEW_CONTRACT_MAINNET)
        self.entrypoint = "default"
    }
    var entrypoint:String
    var value:String
}
