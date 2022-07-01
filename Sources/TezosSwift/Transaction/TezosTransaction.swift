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

public class TezosTransaction {
    public var branch:String {
        return self.metadata.blockHash
    }
    
    public var counter:Int {
        return self.metadata.counter
    }
    
    public var operationDictionary:Dictionary<String,Any>?
    
    public var sendString:String?
    public var contents = [Dictionary<String,Any>]()
    
    var signature = ""\
    var operations = [TezosBaseOperation]()
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
    
    public func addOperation(operation:TezosBaseOperation) {
        operations.append(operation)
        contents.append(operation.payload())
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
    
//    func preapplyAndSignTransaction(keypair:TezosKeypair,successBlock:@escaping (_ sendString:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        operations.forEach { operation in
//            // calculate fee
//            self.calculateFees(operation: operation) {haveFeeOperation in
//                self.resetOperation()
//                // create actual trading operation
//                self.addOperation(operation: haveFeeOperation)
//                // forge transaction
//                self.provider.forge(branch: self.metadata.blockHash, operation: haveFeeOperation) { forgeResult in
//                    if let (operationDictionary,sendString) = self.sign(keypair: keypair, forgeResult: forgeResult) {
//                        //preapply transaction
//                        self.provider.preapplyOperation(operationDictionary:operationDictionary, branch: self.metadata.blockHash) { isSuccess in
//                            if isSuccess {
//                                successBlock(sendString)
//                            } else {
//                                failure(TezosRpcProviderError.server(message: "preapply wrong"))
//                            }
//                        } failure: { error in
//                            failure(error)
//                        }
//                    } else {
//                        failure(TezosRpcProviderError.server(message: "sign wrong"))
//                    }
//                } failure: { error in
//                    failure(error)
//                }
//            } failure: { error in
//                failure(error)
//            }
//        }
//    }
    
    func calculateFees(operation:TezosBaseOperation,successBlock:@escaping (_ haveFeeOperation:TezosBaseOperation)-> Void,failure:@escaping (_ error:Error)-> Void) {
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
    }
        
    
    public func createOperation(operation:TezosBaseOperation,fees: FeesOperation) -> TezosBaseOperation {
        switch operation.type {
        case .XTZ:
            return SendXTZOperation(amount: operation.amount, storage_limit: "\(fees.storageLimit)", gas_limit: "\(fees.gasLimit)", fee:"\(fees.fee)", to: operation.destination, from: operation.source, counter:operation.counter)
        case .FA1_2:
            let sendFa1_2Operation = operation as! SendFa1_2Operation
            return SendFa1_2Operation(amount: sendFa1_2Operation.amount, storage_limit: "\(fees.storageLimit)", gas_limit: "\(fees.gasLimit)", fee: "\(fees.fee)", to: sendFa1_2Operation.to, from: sendFa1_2Operation.source, mintAddress: sendFa1_2Operation.destination, counter: sendFa1_2Operation.counter)
        case .FA2:
            let sendFa2Operation = operation as! SendFa2Operation
            return SendFa2Operation(amount: sendFa2Operation.amount, tokenID: sendFa2Operation.tokenId, storage_limit: "\(fees.storageLimit)", gas_limit: "\(fees.gasLimit)", fee: "\(fees.fee)", to: sendFa2Operation.to, from: sendFa2Operation.source, mintAddress: sendFa2Operation.destination, counter: sendFa2Operation.counter)
        case .DAPP:
            let sendDappOperation = operation as! SendDappOperation
            return SendDappOperation(kind: sendDappOperation.kind, amount: sendDappOperation.amount, storage_limit: "\(fees.storageLimit)", gas_limit: "\(fees.gasLimit)", fee: "\(fees.fee)", to: sendDappOperation.destination, from: sendDappOperation.source, counter: sendDappOperation.counter, parameters: sendDappOperation.parameters)
        }
    }
}
