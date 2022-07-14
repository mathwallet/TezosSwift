//
//  OperationFees.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/13.
//

import Foundation

public let MAXGAS = 800000
public let MAXSTORAGE = 60000
public struct OperationFees {
    var fee:Int
    var gasLimit:Int
    var storageLimit:Int
    var extrafees = ExtraFees()
    public static func + (op1:OperationFees,op2:OperationFees) -> OperationFees {
        return OperationFees(fee: op1.fee+op2.fee, gasLimit: op1.gasLimit+op2.gasLimit, storageLimit: op1.storageLimit+op2.storageLimit,extrafees:op1.extrafees + op2.extrafees)
    }
}

public struct CalculatedFees{
    let operationFees: [OperationFees]
    let accumulatedFee: OperationFees
    
    var calculateAccumulated:OperationFees {
        var accumulatedFees = OperationFees(fee: 0, gasLimit: 0, storageLimit: 0)
        operationFees.forEach { OperationFees in
            accumulatedFees = accumulatedFees + OperationFees
        }
        return accumulatedFees
    }
}

