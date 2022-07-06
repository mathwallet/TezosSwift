//
//  SimulationResponse.swift
//  
//
//  Created by xgblin on 2022/7/6.
//

import Foundation

// MARK: transation
public struct SimulationResponse {
    public var simulations:[SimulatedFees]
}

public struct SimulatedFees {
    public var type:String
    public var extraFees:ExtraFees
    public var consumedGas:Int
    public var consumedStorage:Int
}

public struct ExtraFees {
    public var burnFees = [ExtraFee]()
    public var allocationFees = [ExtraFee]()
    public var originationFees = [ExtraFee]()
    
    public mutating func add(extraFee:ExtraFee) {
        switch extraFee.type {
        case .ORIGINATION_FEE:
            originationFees.append(extraFee)
        case .ALLOCATION_FEE:
            allocationFees.append(extraFee)
        case .BURN_FEE:
            burnFees.append(extraFee)
        }
    }
    
    public static func + (fees1:ExtraFees,fees2:ExtraFees) -> ExtraFees {
        var burnFees = fees1.burnFees
        burnFees.append(contentsOf: fees2.burnFees)
        
        var allocationFees = fees1.allocationFees
        allocationFees.append(contentsOf: fees2.allocationFees)
        
        var originationFees = fees1.originationFees
        originationFees.append(contentsOf: fees2.originationFees)
        return ExtraFees(burnFees: burnFees, allocationFees: allocationFees, originationFees: originationFees)
    }
    
    public static func += (fees1: inout ExtraFees,fees2:ExtraFees) {
        fees1 = fees1 + fees2
    }
}

public struct BurnFee:ExtraFee {
    public var type:ExtraFeeType
    public var fee:String
    public init(feeString:String) {
        type = .BURN_FEE
        fee = feeString
    }
}

public struct AllocationFee:ExtraFee {
    public var type:ExtraFeeType
    public var fee:String
    public init(feeString:String) {
        type = .ALLOCATION_FEE
        fee = feeString
    }
}

public struct OriginationFee:ExtraFee {
    public var type:ExtraFeeType
    public var fee:String
    public init(feeString:String) {
        type = .ORIGINATION_FEE
        fee = feeString
    }
}

public protocol ExtraFee {
    var type:ExtraFeeType {get}
    var fee:String {set get}
}

public enum ExtraFeeType:String {
    case BURN_FEE
    case ALLOCATION_FEE
    case ORIGINATION_FEE
}
