//
//  TezosRPCResult.swift
//  
//
//  Created by xgblin on 2022/6/10.
//

import Foundation

// MARK: ChainHead
public struct GetChainHeadResult:Codable {
    var hash:String?
    var chaid_id:String?
    var protocolString:String?
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
    var data:GetTokenBalanceDataResult?
    
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
    var int:String?
}

// MARK: NetworkConstants

public struct TezosNetworkConstants:Codable {
    var hard_gas_limit_per_operation: String?
    var hard_storage_limit_per_operation: String?
    var hard_gas_limit_per_block: String?
    var origination_size: Int?
    var cost_per_byte: String?
}

// MARK: Metadata
public struct TezosBlockchainMetadata {
    var blockHash: String
    var protocolString: String
    var chainId: String?
    var counter: Int
    var key: String
    var constants: TezosNetworkConstants
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

public struct SimulationResponse:Codable {
    var simulations:[SimulatedFees]
}

public struct SimulatedFees:Codable {
    var type:String
    var extraFees:[ExtraFee]
    var consumedGas:Int
    var consumedStorage:Int
}

public struct ExtraFee:Codable {
    var fee:Int
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

