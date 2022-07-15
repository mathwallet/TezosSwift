//
//  RunOperationParmater.swift
//  
//
//  Created by xgblin on 2022/7/14.
//

import Foundation

public struct RunOperationParmater: Encodable {
    public let operation: SignedRunOperationPayload
    public let chain_id: String
}
