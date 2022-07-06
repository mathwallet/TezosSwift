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
    var extrafees = [ExtraFee]()
    static public func + (op1:FeesOperation,op2:FeesOperation) -> FeesOperation {
        var newExtrafees = [ExtraFee]()
        op1.extrafees.forEach { extraFee in
            newExtrafees.append(extraFee)
        }
        op2.extrafees.forEach { extraFee in
            newExtrafees.append(extraFee)
        }
        return FeesOperation(fee: op1.fee+op2.fee, gasLimit: op1.gasLimit+op2.gasLimit, storageLimit: op1.storageLimit+op2.storageLimit,extrafees:newExtrafees)
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

