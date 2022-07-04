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
    
    public var operationDictionary:[String:Any]?
    
    public var sendString:String?
    public var contents = [[String:Any]]()
    
    var signature = ""
    var operations = [Tezos.Operation]()
    var metadata:TezosBlockchainMetadata
    var forgeString:String?
    
    let provider:TezosRpcProvider
    public init(nodeUrl:String,metadata:TezosBlockchainMetadata) {
        self.provider = TezosRpcProvider(nodeUrl: nodeUrl)
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
    
    public convenience init(nodeUrl:String,from:String,to:String,mint:String = "",amount:BigUInt,tokenType:TezosTransactionType,tokenId: String = "",metadata:TezosBlockchainMetadata) {
        self.init(nodeUrl: nodeUrl, metadata: metadata)
        let operation = TezosOperationUtil.createOperation(from: from, to: to, counter:"\(metadata.counter)" , amount: amount.description, tokenType: tokenType, tokenId: tokenId,metadata:metadata)
        self.operations.append(operation)
    }
    
    public convenience init(nodeUrl:String,operation:Tezos.Operation,metadata:TezosBlockchainMetadata) {
        self.init(nodeUrl: nodeUrl, metadata: metadata)
        self.operations.append(operation)
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
    
    func calculateFees(operation:Tezos.Operation,successBlock:@escaping (_ haveFeeOperation:Tezos.Operation)-> Void,failure:@escaping (_ error:Error)-> Void) {
        switch operation{
        case .transaction(_),.reveal(_),.origination(_),.delegation(_):
            provider.getSimulationResponse(metadata: self.metadata, operation: operation) { response in
                let service = TezosFeeEstimatorService()
                self.provider.forge(branch:self.metadata.blockHash ,operation: operation) { forgeResult in
                    let fee = service.calculateFees(response: response, operationSize: service.getForgedOperationsSize(forgeResult: forgeResult))
                    let haveFeeOperation =  self.createOperation(operation: operation,fees:fee.accumulatedFee)
                     successBlock(haveFeeOperation)
                } failure: { error in
                    failure(error)
                }
            } failure: { error in
                failure(error)
            }
        default:
            successBlock(operation)
        }
    }
        
    public func createOperation(operation:Tezos.Operation,fees: FeesOperation) -> Tezos.Operation {
        switch operation {
        case let .transaction(content):
            return Tezos.Operation.transaction(Tezos.Operation.Transaction(source:content.source , fee:"\(fees.fee)" , counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", amount: content.amount, destination: content.destination, parameters: content.parameters))
        case let .reveal(content):
            return Tezos.Operation.reveal(Tezos.Operation.Reveal(source: content.source, fee: "\(fees.fee)", counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", publicKey: content.publicKey))
        case let .origination(content):
            return Tezos.Operation.origination(Tezos.Operation.Origination(source: content.source, fee: "\(fees.fee)", counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", balance: content.balance, delegate: content.delegate, script: content.script))
        case let .delegation(content):
            return Tezos.Operation.delegation(Tezos.Operation.Delegation(source: content.source, fee: "\(fees.fee)", counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", delegate: content.delegate))
        default :
            return operation
        }
    }
}

public enum TezosTransactionType {
    case XTZ
    case FA1_2
    case FA2
}
