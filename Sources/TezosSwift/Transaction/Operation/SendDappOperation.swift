//
//  SendDappOperation.swift
//  
//
//  Created by xgblin on 2022/7/1.
//

import Foundation

public struct SendDappOperation:TezosBaseOperation {
    public var type:TezosTransactionType = .DAPP
    public var kind:String
    public var source: String
    public var destination: String
    public var fee: String
    public var counter: String
    public var gas_limit: String
    public var storage_limit: String
    public var amount: String
    public var parameters:Dictionary<String, Any>
    
    public init(
        kind:String,
        amount:String,
        storage_limit:String,
        gas_limit:String,
        fee:String,
        to:String,
        from:String,
        counter:String,
        parameters:Dictionary<String, Any>
    ) {
        self.kind = kind
        self.amount = amount
        self.storage_limit = storage_limit
        self.gas_limit = gas_limit
        self.kind = kind
        self.fee = fee
        self.destination = to
        self.source = from
        self.counter = counter
        self.parameters = parameters
    }
    
    public func payload() -> Dictionary<String, Any> {
        return [
            "kind":kind,
            "source":source,
            "fee":fee,
            "counter":counter,
            "gas_limit":gas_limit,
            "storage_limit":storage_limit,
            "amount":amount,
            "destination":destination,
            "parameters":parameters
        ]
    }
}
