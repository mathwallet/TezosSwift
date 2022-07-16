//
//  TezosTransaction.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/14.
//

import Foundation
import Base58Swift
import CryptoSwift
import BigInt

public class TezosTransaction {

    public var metadata:TezosBlockchainMetadata
    public var operations = [TezosOperation]()
    
    public var forgeString:String?
    public var signatureString:String?
    public var sendString:String?
    
    public var branch:String {
        return self.metadata.blockHash
    }
    
    public var counter:Int {
        return self.metadata.counter
    }
    
    public var protocolString:String {
        return self.metadata.protocolString
    }
    
    public init(metadata:TezosBlockchainMetadata) {
        self.metadata = metadata
    }
    
    public func addOperation(_ operation:TezosOperation) {
        self.operations.append(operation)
    }
    
    public func resetOperations() {
        self.operations.removeAll()
    }
    
    public func configOperations(operations:[TezosOperation]) {
        self.operations.removeAll()
        self.operations.append(contentsOf: operations)
    }

    public func sign(keypair: TezosKeypair) {
        if let _forgeString = self.forgeString, let signatureData = self.signHexString(keypair: keypair, hexString:_forgeString) {
            self.signatureString = Base58.base58CheckEncode(TezosPrefix.edsig + signatureData.bytes)
            self.sendString = _forgeString + signatureData.toHexString()
        }
    }
    
    func signHexString(keypair:TezosKeypair, hexString:String) -> Data? {
        let messageBytes = [3] + Data(hex: hexString).bytes
        
        guard let prepareData = try? Data(messageBytes).genericHash(outputLength: 32) else {
            return nil
        }
        return try? keypair.signDigest(messageDigest: prepareData)
    }
}

public enum TezosTransactionType {
    case XTZ
    case FA1_2
    case FA2
}

