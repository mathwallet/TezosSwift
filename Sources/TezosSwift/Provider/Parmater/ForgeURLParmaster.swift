//
//  ForgeURLParmaster.swift
//  
//
//  Created by xgblin on 2022/7/14.
//

import Foundation

public struct ForgeURLParmaster:Encodable {
    public let contents: [TransactionOperation]
    public let branch: String
}
