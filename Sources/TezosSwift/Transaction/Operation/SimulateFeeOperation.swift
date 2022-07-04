//
//  SimulateFeeOperation.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/21.
//

import Foundation
import BeaconBlockchainTezos

public struct SimulateFeeOperation {
    var branch:String
    var signature = "edsigtkpiSSschcaCt9pUVrpNPf7TTcgvgDEDD6NCEHMy8NNQJCGnMfLZzYoQj74yLjo9wx6MPVV29CvVzgi7qEcEUok3k7AuMg"
    var operation:Tezos.Operation
    var chain_id:String
    init(operation:Tezos.Operation,metadata:TezosBlockchainMetadata) {
        self.branch = metadata.blockHash
        self.chain_id = metadata.chainId!
        self.operation = operation
    }
    
    public func payload() -> Dictionary<String, Any> {
        return [
            "chain_id":chain_id,
            "operation":[
                "branch":"",
                "contents":[
//                    operation.payload()
                ],
                "signature":signature
            ]
        ]
    }
}
