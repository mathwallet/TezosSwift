//
//  TransactionF2Operation.swift
//  
//
//  Created by xgblin on 2022/7/13.
//

import Foundation

public class TransactionF2Operation: TransactionOperation {
    public init(from: String, to: String,mint:String, counter: String, amount: String,tokenId:String = "0",kind: TezosOperationKind = .transaction, operationFees: OperationFees? = nil)  {
        super.init(source: from, counter: counter, destination: mint, amount: "0", kind: kind, operationFees: operationFees ?? defultoperationFees)
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
