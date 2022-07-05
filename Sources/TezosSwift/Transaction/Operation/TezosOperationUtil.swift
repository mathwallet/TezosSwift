//
//  TezosOperationUtil.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/15.
//

import Foundation
import BeaconBlockchainTezos

typealias TezosArg = Micheline.MichelsonV1Expression
typealias TezosPrim = Micheline.Prim
typealias TezosParameters = Tezos.Operation.Parameters

public struct TezosOperationUtil {
    
    static func createOperation(from:String,to:String,mint:String = "",counter:String,amount:String,tokenType:TezosTransactionType,tokenId: String,metadata:TezosBlockchainMetadata)  -> Tezos.Operation {
        switch tokenType {
        case .XTZ:
            return Tezos.Operation.transaction(Tezos.Operation.Transaction(source: from, fee: "0", counter: counter, gasLimit: MAXGAS, storageLimit: MAXSTORAGE, amount: amount, destination: to, parameters: nil))
        case .FA1_2:
            return Tezos.Operation.transaction(Tezos.Operation.Transaction(source: from, fee: "0", counter: counter, gasLimit: MAXGAS, storageLimit: MAXSTORAGE, amount: "0", destination: mint, parameters: self.fa1_2Parameters(from: from, to: to, amount: amount)))
        case .FA2:
            return Tezos.Operation.transaction(Tezos.Operation.Transaction(source: from, fee: "0", counter: counter, gasLimit: MAXGAS, storageLimit: MAXSTORAGE, amount: "0", destination: mint, parameters: self.fa2Parameters(from: from, to: to, amount: amount,tokenId: tokenId)))
        }
    }
    
    static func fa1_2Parameters(from:String,to:String,amount:String) -> Tezos.Operation.Parameters {
        let amountArgs:[Micheline.MichelsonV1Expression] = [TezosArg.literal(Micheline.Literal.string(to)),TezosArg.literal(Micheline.Literal.int(amount))]
        let amountPrim = TezosPrim(prim: "Pair", args: amountArgs)
        
        let fromArgs = [TezosArg.literal(Micheline.Literal.string(from)),TezosArg.prim(amountPrim)]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        
        return TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.prim(valuePrim))
        
    }
    
    static func fa2Parameters(from:String,to:String,amount:String,tokenId:String) -> Tezos.Operation.Parameters {
        let amountArgs:[Micheline.MichelsonV1Expression] = [TezosArg.literal(Micheline.Literal.string(tokenId)),TezosArg.literal(Micheline.Literal.int(amount))]
        let amountPrim = TezosPrim(prim: "Pair", args: amountArgs)
        
        let toArgs = [TezosArg.literal(Micheline.Literal.string(to)),TezosArg.prim(amountPrim)]
        let toPrim = TezosPrim(prim: "Pair", args:toArgs)
        
        let fromArgs = [TezosArg.literal(Micheline.Literal.string(from)),TezosArg.prim(toPrim)]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        
        return TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.prim(valuePrim))
        
    }
    
    static func operationPayload(operation:Tezos.Operation) -> [String:Any]? {
        guard let data = try? JSONEncoder().encode(operation),var result = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any],var parameters = result["parameters"] as? [String:Any] else {
            return nil
        }
        parameters.keys.sorted {($0.count > $1.count)}
        return result
    }
}
