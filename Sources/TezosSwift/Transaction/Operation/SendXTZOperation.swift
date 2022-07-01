//
//  SendXTZOperation.swift
//  MathWalvar5
//
//  Created by xgblin on 2022/6/13.
//

import Foundation

public struct SendXTZOperation:TezosBaseOperation {
    public var type:TezosTransactionType = .XTZ
    public var kind:String
    public var source:String
    public var destination:String
    public var storage_limit:String
    public var gas_limit:String
    public var fee:String
    public var amount:String
    public var counter:String
    
    public init(amount:String,
         storage_limit:String,
         gas_limit:String,
         fee:String,
         to:String,
         from:String,
         counter:String) {
        self.amount = amount
        self.storage_limit = storage_limit
        self.gas_limit = gas_limit
        self.kind = "transaction"
        self.fee = fee
        self.destination = to
        self.source = from
        self.counter = counter
    }
    public func payload() -> Dictionary<String, Any> {
        return [
            "kind":"transaction",
            "source":source,
            "fee":fee,
            "counter":counter,
            "gas_limit":gas_limit,
            "storage_limit":storage_limit,
            "amount":amount,
            "destination":destination
        ]
    }
}
