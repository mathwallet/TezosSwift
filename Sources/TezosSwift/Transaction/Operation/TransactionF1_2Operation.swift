//
//  TransactionF1_2Operation.swift
//  
//
//  Created by 薛跃杰 on 2022/7/13.
//

import Foundation

public class TransactionF1_2Operation: TransactionOperation {
    let to:String
    public override init(from: String, to: String,mint:String, counter: String, amount: String, kind: TezosOperationKind = .transaction, operationFees: OperationFees? = nil) {
        self.source = source
        self.destination = mint
        self.to = to
        self.counter = counter
        self.amount = "0"
        self.kind = kind
        self.operationFees = operationFees
        self.parameters = self.createTezosParameters(from:from, to: to, amount: amount)
    }
    
    private func createTezosParameters(from:String,to:String,amount:String) -> TezosParameters {
        let amountArgs:[TezosArg] = [TezosArg.literal(TezosLiteral.string(to)),TezosArg.literal(TezosLiteral.int(amount))]
        let amountPrim = TezosPrim(prim: "Pair",args: amountArgs)
        
        let fromArgs:[TezosArg] = [TezosArg.literal(Micheline.Literal.string(from)),TezosArg.prim(amountPrim)]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        
        return TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.prim(valuePrim))
    }
}
