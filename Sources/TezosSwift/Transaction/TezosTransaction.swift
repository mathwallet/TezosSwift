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
    public var signature = ""
    public var contents = [Dictionary<String,Any>]()
    public var operations = [TezosBaseOperation]()
    public var metaData:TezosBlockchainMetadata
    let provider:TezosRpcProvider
    public init(nodeUrl:String,metaData:TezosBlockchainMetadata) {
        self.provider = TezosRpcProvider(nodeUrl: nodeUrl)
        self.metaData = metaData
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
    
    func sign(keypair:TezosKeypair,forgeResult:String) -> (Dictionary<String,Any>,String)? {
        guard let signatureData = self.signHexString(keypair: keypair, hexString:forgeResult) else {
            return nil
        }
        let signatureString = Base58.base58CheckEncode(TezosPrefix.edsig + signatureData.bytes)
        let sendString = forgeResult + signatureData.toHexString()
        return ([
            "branch":self.metaData.blockHash,
            "contents":contents,
            "protocol":self.metaData.protocolString,
            "signature":signatureString
        ],sendString)
    }
    
    public func preapplyAndSignTransaction(keypair:TezosKeypair,successBlock:@escaping (_ sendString:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        operations.forEach { operation in
            // calculate fee
            self.calculateFees(operation: operation) {haveFeeOperation in
                self.resetOperation()
                // create actual trading operation
                self.addOperation(operation: haveFeeOperation)
                // forge transaction
                self.provider.forge(branch: self.metaData.blockHash, operation: haveFeeOperation) { forgeResult in
                    if let (operationDictionary,sendString) = self.sign(keypair: keypair, forgeResult: forgeResult) {
                        //preapply transaction
                        self.provider.preapplyOperation(operationDictionary:operationDictionary, branch: self.metaData.blockHash) { isSuccess in
                            if isSuccess {
                                successBlock(sendString)
                            } else {
                                failure(TezosRpcProviderError.server(message: "preapply wrong"))
                            }
                        } failure: { error in
                            failure(error)
                        }
                    } else {
                        failure(TezosRpcProviderError.server(message: "sign wrong"))
                    }
                } failure: { error in
                    failure(error)
                }
            } failure: { error in
                failure(error)
            }
        }
    }
    
    func calculateFees(operation:TezosBaseOperation,successBlock:@escaping (_ haveFeeOperation:TezosBaseOperation)-> Void,failure:@escaping (_ error:Error)-> Void) {
        provider.getSimulationResponse(metaData: self.metaData, operation: operation) { response in
            let service = TezosFeeEstimatorService()
            self.provider.forge(branch:self.metaData.blockHash ,operation: operation) { forgeResult in
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
        }
    }
}