//
//  TezosBaseOperation.swift
//  
//
//  Created by xgblin on 2022/6/10.
//

import Foundation

public protocol TezosBaseOperation:TezosOperation {
    var type:TezosTransactionType{set get}
    var kind:String{set get}
    var source:String{set get}
    var destination:String{set get}
    var storage_limit:String{set get}
    var gas_limit:String{set get}
    var fee:String{set get}
    var amount:String{set get}
    var counter:String{set get}
}

public enum TezosTransactionType {
    case XTZ
    case FA1_2
    case FA2
}
