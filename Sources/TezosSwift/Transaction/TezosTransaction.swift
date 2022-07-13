//
//  TezosTransaction.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/14.
//

import Foundation
import Base58Swift
import Sodium
import CryptoSwift
import BigInt
import BeaconBlockchainTezos

public class TezosTransaction {
    public var branch:String {
        return self.metadata.blockHash
    }
    
    public var counter:Int {
        return self.metadata.counter
    }
    
    public var kind:String {
        return self.transactionKind()
    }
    
    public var operationDictionary:[String:Any]?
    
    public var sendString:String?
    public var contents = [[String:Any]]()
    public var operations = [Tezos.Operation]()
    
    var metadata:TezosBlockchainMetadata
    var forgeString:String?
    
    public init(metadata:TezosBlockchainMetadata) {
        self.metadata = metadata
    }
    
    public func resetOperation() {
        operations.removeAll()
        contents.removeAll()
    }
    
    public func addOperation(operation:Tezos.Operation) {
        operations.append(operation)
        if let operationPayload = TezosOperationUtil.operationPayload(operation: operation) {
            contents.append(operationPayload)
        }
    }
    
    public convenience init(from:String,to:String,mint:String = "",amount:BigUInt,tokenType:TezosTransactionType,tokenId: String = "",metadata:TezosBlockchainMetadata) {
        self.init(metadata: metadata)
        let operation = TezosOperationUtil.createOperation(from: from, to: to,mint:mint, counter:"\(metadata.counter)" , amount: amount.description, tokenType: tokenType, tokenId: tokenId,metadata:metadata)
        self.addOperation(operation: operation)
    }
    
    public convenience init(from:String,operation:Tezos.Operation,metadata:TezosBlockchainMetadata) {
        self.init(metadata: metadata)
        let operation = TezosOperationUtil.createDappOperation(operation: operation, from: from, metadata: metadata)
        self.addOperation(operation: operation)
    }
    
    func signHexString(keypair:TezosKeypair,hexString:String) -> Data? {
        guard let prepareBytes = Sodium().genericHash.hash(message: [3] + Data(hex: hexString).bytes, outputLength: 32)else{
            return nil
        }
        let prepareData = Data(prepareBytes)
        return keypair.signDigest(messageDigest: prepareData)
    }
    
    public func sign(keypair:TezosKeypair) {
        if let _forgeString = self.forgeString, let signatureData = self.signHexString(keypair: keypair, hexString:_forgeString) {
            let signatureString = Base58.base58CheckEncode(TezosPrefix.edsig + signatureData.bytes)
            self.sendString = _forgeString + signatureData.toHexString()
            self.operationDictionary = [
                "branch":self.metadata.blockHash,
                "contents":contents,
                "protocol":self.metadata.protocolString,
                "signature":signatureString
            ]
        }
    }
    
    func transactionKind() -> String {
        if let operation = self.operations.first {
            switch operation {
            case let .transaction(content):
                return content.kind.rawValue
            case let .endorsement(content):
                return content.kind.rawValue
            case let .seedNonceRevelation(content):
                return content.kind.rawValue
            case let .doubleEndorsementEvidence(content):
                return content.kind.rawValue
            case let .doubleBakingEvidence(content):
                return content.kind.rawValue
            case let .activateAccount(content):
                return content.kind.rawValue
            case let .proposals(content):
                return content.kind.rawValue
            case let .ballot(content):
                return content.kind.rawValue
            case let .reveal(content):
                return content.kind.rawValue
            case let .origination(content):
                return content.kind.rawValue
            case let .delegation(content):
                return content.kind.rawValue
            }
        } else {
            return ""
        }
    }
}

public enum TezosTransactionType {
    case XTZ
    case FA1_2
    case FA2
}
