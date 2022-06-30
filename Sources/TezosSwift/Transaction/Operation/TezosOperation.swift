//
//  TezosOperation.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/15.
//

import Foundation

public protocol TezosOperation {
    func payload() -> Dictionary<String,Any>
}
