//
//  TezosRPCResult.swift
//  
//
//  Created by xgblin on 2022/6/10.
//

import Foundation
import BeaconBlockchainTezos

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

// MARK: GET BALANCE FA2

public struct FA2BalanceResult:Codable {
    var data:[Micheline.Prim]?
    var balance:String {
        guard let prim = data?.first,let args = prim.args,let literal = args[1] else {
            return ""
        }
        switch literal {
        case let .int(balance):
            return balance
        default:
            return ""
        }
    }
}

// MARK: GET BALANCE FA1.2
public struct FA1_2BalanceResult:Codable {
    var data:FA1_2ResultData?
}
public struct FA1_2ResultData:Codable {
    var int:String?
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

