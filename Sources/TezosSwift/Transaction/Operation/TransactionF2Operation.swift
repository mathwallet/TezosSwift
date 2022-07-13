//
//  TransactionF2Operation.swift
//  
//
//  Created by 薛跃杰 on 2022/7/13.
//

import Foundation

public class TransactionF2Operation: TransactionOperation {
    let to:String
    public override init(from: String, to: String,mint:String, counter: String, amount: String,tokenId:String, kind: TezosOperationKind = .transaction, operationFees: OperationFees? = nil) {
        self.source = from
        self.destination = mint
        self.to = to
        self.counter = counter
        self.amount = "0"
        self.kind = kind
        self.operationFees = operationFees
        self.parameters = self.createTezosParameters(from:from, to: to, amount: amount,tokenId: tokenId)
    }
    
    private func createTezosParameters(from:String,to:String,amount:String,tokenId:String) -> TezosParameters {
        let amountArgs:[TezosArg] = [TezosArg.literal(TezosLiteral.int(tokenId)),TezosArg.literal(TezosLiteral.int(amount))]
        let amountPrim = TezosPrim(prim: "Pair", args: amountArgs)
        
        let toArgs:[TezosArg] = [TezosArg.literal(TezosLiteral.string(to)),TezosArg.prim(amountPrim)]
        let toPrim = TezosPrim(prim: "Pair", args:toArgs)
        
        let fromArgs = [TezosArg.literal(TezosLiteral.string(from)),TezosArg.sequence([TezosArg.prim(toPrim)])]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        
        return TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.sequence([TezosArg.prim(valuePrim)]))
    }
}
