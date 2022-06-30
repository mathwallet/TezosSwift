//
//  SendFa2Operation.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/14.
//

import Foundation

public struct SendFa2Operation:TezosBaseOperation {
    public var type:TezosTransactionType = .FA2
    public var kind:String
    public var source:String
    public var destination:String
    public var storage_limit:String
    public var gas_limit:String
    public var fee:String
    public var amount:String
    public var counter:String
    public var parameters:Dictionary<String, Any>
    public var to:String
    public var tokenId:String
    
    public init(amount:String,
         tokenID:String,
         storage_limit:String,
         gas_limit:String,
         fee:String = "0",
         to:String,
         from:String,
         mintAddress:String,
         counter:String) {
        self.amount = amount
        self.storage_limit = storage_limit
        self.gas_limit = gas_limit
        self.kind = "transaction"
        self.fee = fee
        self.destination = mintAddress
        self.to = to
        self.source = from
        self.counter = counter
        self.tokenId = tokenID
        self.parameters = [
            "entrypoint":"transfer",
            "value":[
                [
                    "prim":"Pair",
                    "args":[
                        [
                            "string":from
                        ],
                        [
                            [
                                "prim":"Pair",
                                "args":[
                                    [
                                        "string":to
                                    ],
                                    [
                                        "prim":"Pair",
                                        "args":[
                                            [
                                                "int":tokenID
                                            ],
                                            [
                                                "int":amount
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
    
    public func payload() -> Dictionary<String, Any> {
        return [
            "kind":"transaction",
            "source":source,
            "fee":fee,
            "counter":counter,
            "gas_limit":gas_limit,
            "storage_limit":storage_limit,
            "amount":"0",
            "destination":destination,
            "parameters":parameters
        ]
    }
}
