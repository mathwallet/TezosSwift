//
//  FeesOperation.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/13.
//

import Foundation

public let MAXGAS = "800000"
public let MAXSTORAGE = "60000"
public struct FeesOperation {
    var fee:Int
    var gasLimit:Int
    var storageLimit:Int
    var extrafees = ExtraFees()
    public static func + (op1:FeesOperation,op2:FeesOperation) -> FeesOperation {
        let newExtrafees = op1.extrafees + op2.extrafees
        return FeesOperation(fee: op1.fee+op2.fee, gasLimit: op1.gasLimit+op2.gasLimit, storageLimit: op1.storageLimit+op2.storageLimit,extrafees:op1.extrafees + op2.extrafees)
    }
}

public struct CalculatedFees{
    let operationFees: [FeesOperation]
    let accumulatedFee: FeesOperation
    
    var calculateAccumulated:FeesOperation {
        var accumulatedFees = FeesOperation(fee: 0, gasLimit: 0, storageLimit: 0)
        operationFees.forEach { feesOperation in
            accumulatedFees = accumulatedFees + feesOperation
        }
        return accumulatedFees
    }
}

