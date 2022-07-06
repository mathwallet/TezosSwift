//
//  TezosRPCResult.swift
//  
//
//  Created by xgblin on 2022/6/10.
//

import Foundation

// MARK: ChainHead
public struct GetChainHeadResult:Codable {
    public var hash:String?
    public var chaid_id:String?
    public var protocolString:String?
    enum CodingKeys: String, CodingKey {
            case hash
            case chaid_id
            case protocolString = "protocol"
        }
}
 
// MARK: TokenBalance
//fa1.2Balance
public protocol GetTokenBalanceBase:Codable {
    func balance() -> String
}

public struct GetFA1_2TokenBalanceResult:GetTokenBalanceBase {
    public var data:GetTokenBalanceDataResult?
    
    public func balance() -> String {
        guard let dataResult = data, let balance = dataResult.int else {
            return ""
        }
        return balance
    }
}
// MARK: TokenBalance
//fa2Balance
public struct GetTokenBalanceDataResult:Codable {
    public var int:String?
}

// MARK: NetworkConstants

public struct TezosNetworkConstants:Codable {
    public var hard_gas_limit_per_operation: String?
    public var hard_storage_limit_per_operation: String?
    public var hard_gas_limit_per_block: String?
    public var origination_size: Int?
    public var cost_per_byte: String?
}

// MARK: Metadata
public struct TezosBlockchainMetadata {
    public var blockHash: String
    public var protocolString: String
    public var chainId: String?
    public var counter: Int
    public var key: String
    public var constants: TezosNetworkConstants
}

// MARK: transation
public struct SimulationResult:Codable {
    public var contents:[SimulationResultContent]?
    public var signature:String?
}

public struct SimulationResultContent:Codable {
    public var kind:String?
    public var source:String?
    public var fee:String?
    public var counter:String?
    public var gas_limit:String?
    public var storage_limit:String?
    public var amount:String?
    public var destination:String?
    public var metadata:SimulationResultMetadata
}

public struct SimulationResultMetadata:Codable {
    public var balance_updates:[String]?
    public var operation_result:SimulationResultMetadataOperation?
}

public struct SimulationResultMetadataOperation:Codable {
    public var status:String?
    public var consumed_gas:String?
    public var consumed_milligas:String?
    public var balance_updates:[SimulationResultMetadataOperationBalanceipdate]?
}

public struct SimulationResultMetadataOperationBalanceipdate:Codable {
    public var kind:String?
    public var contract:String?
    public var change:String?
    public var origin:String?
}

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

// MARK: NFT

public struct TezosNFTResult:Codable {
    public var balance:String?
    public var count:String {
        return balance ?? ""
    }
    public var tokenID:String {
        return token?.tokenId ?? ""
    }
    public var image:String {
        return token?.metadata?.displayUri ?? ""
    }
    public var description:String {
        return token?.metadata?.description ?? ""
    }
    public var name:String {
        return token?.metadata?.name ?? ""
    }
    public var mint:String {
        return token?.contract?.address ?? ""
    }
    public var symbol:String {
        return token?.metadata?.symbol ?? ""
    }
    
    public var type:String {
        return token?.metadata?.type ?? ""
    }
    
    public var token:TezosNFTResultToken?
}


public struct TezosNFTResultToken:Codable {
    public var tokenId:String?
    public var metadata:TezosNFTResultMetadata?
    public var contract:TezosNFTResultcontract?
}

public struct TezosNFTResultcontract:Codable {
    public var address:String?
}

public struct TezosNFTResultMetadata:Codable {
    public var name:String?
    public var displayUri:String?
    public var description:String?
    public var symbol:String?
    public var type:String?
}

