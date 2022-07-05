//
//  TezosOperationUtil.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/15.
//

import Foundation
import BeaconBlockchainTezos
import UIKit

typealias TezosArg = Micheline.MichelsonV1Expression
typealias TezosPrim = Micheline.Prim
typealias TezosParameters = Tezos.Operation.Parameters

public struct TezosOperationUtil {
    
    static func createDappOperation(operation:Tezos.Operation,from:String,metadata:TezosBlockchainMetadata)  -> Tezos.Operation {
        switch operation {
        case let .transaction(content):
            return .transaction(Tezos.Operation.Transaction(source: from, fee: "0", counter: "\(metadata.counter)", gasLimit: MAXGAS, storageLimit: content.storageLimit, amount: content.amount, destination: content.destination, parameters: content.parameters))
        case let .endorsement(content):
            return .endorsement(Tezos.Operation.Endorsement(level: content.level))
        case let .seedNonceRevelation(content):
            return .seedNonceRevelation(Tezos.Operation.SeedNonceRevelation(level: content.level, nonce: content.nonce))
        case let .doubleEndorsementEvidence(content):
            return .doubleEndorsementEvidence(Tezos.Operation.DoubleEndorsementEvidence(op1: content.op1, op2: content.op2))
        case let .doubleBakingEvidence(content):
            return .doubleBakingEvidence(Tezos.Operation.DoubleBakingEvidence(bh1: content.bh1, bh2: content.bh2))
        case let .activateAccount(content):
            return .activateAccount(Tezos.Operation.ActivateAccount(pkh: content.pkh, secret: content.secret))
        case let .proposals(content):
            return .proposals(Tezos.Operation.Proposals(period: content.period, proposals: content.proposals))
        case let .ballot(content):
            return .ballot(Tezos.Operation.Ballot(source: from, period: content.period, proposal: content.proposal, ballot: content.ballot))
        case let .reveal(content):
            return .reveal(Tezos.Operation.Reveal(source: from, fee: "0", counter: "\(metadata.counter)", gasLimit: MAXGAS, storageLimit: content.storageLimit, publicKey: content.publicKey))
        case let .origination(content):
            return .origination(Tezos.Operation.Origination(source: from, fee: "0", counter: "\(metadata.counter)", gasLimit: MAXGAS, storageLimit: content.storageLimit, balance: content.balance, delegate: content.delegate, script: content.script))
        case let .delegation(content):
            return .delegation(Tezos.Operation.Delegation(source: from, fee: "0", counter: "\(metadata.counter)", gasLimit: MAXGAS, storageLimit: content.storageLimit, delegate: content.delegate))
        }
    }
    
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
        let amountArgs:[Micheline.MichelsonV1Expression] = [TezosArg.literal(Micheline.Literal.int(tokenId)),TezosArg.literal(Micheline.Literal.int(amount))]
        let amountPrim = TezosPrim(prim: "Pair", args: amountArgs)
        
        let toArgs = [TezosArg.literal(Micheline.Literal.string(to)),TezosArg.prim(amountPrim)]
        let toPrim = TezosPrim(prim: "Pair", args:toArgs)
        
        let fromArgs = [TezosArg.literal(Micheline.Literal.string(from)),TezosArg.sequence([TezosArg.prim(toPrim)])]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        
        return TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.sequence([TezosArg.prim(valuePrim)]))
        
    }
    
    static func operationPayload(operation:Tezos.Operation) -> [String:Any]? {
        guard let data = try? JSONEncoder().encode(operation),let result = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] else {
            return nil
        }
        return result
    }
}
