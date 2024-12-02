//
//  RPCSimulateOperationParmater.swift
//  TezosSwift
//
//  Created by xgblin on 2024/11/29.
//

import Foundation

public struct RPCSimulateOperationParmater: Encodable {
    public let operation: SignedRunOperationPayload
    public let chain_id: String
}
