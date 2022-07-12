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

public struct GetHeadHeaderResult:Codable {
    public var level:Int?
}
 
// MARK:  GET BALANCE XTZ
public struct GetTokenBalanceDataResult:Codable {
    public var int:String?
}
// MARK: GET BALANCE FA1.2
public struct FA1_2BalanceResult:Codable {
    var data:FA1_2ResultData?
    public var balance:String {
        guard let result = data,let balance = result.int else {
            return ""
        }
        return balance
    }
    
}
public struct FA1_2ResultData:Codable {
    var int:String?
}
// MARK: GET BALANCE FA2

public struct FA2BalanceResult:Codable {
    var data:[Micheline.Prim]?
    public var balance:String {
        guard let prim = data?.first,let args = prim.args else {
            return ""
        }
        let expression = args[1]
        switch expression {
        case let .literal(literal):
            switch literal {
            case let .int(balance):
                return balance
            default :
                return ""
            }
        default :
            return ""
        }
    }
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

// MARK: SimulationResponse
public struct TezosSimulationResult:Codable {
    var contents:[TezosSimulationContent]?
    var signature:String?
}

public struct TezosSimulationContent:Codable {
    var kind:String?
    var source:String?
    var fee:String?
    var counter:String?
    var gas_limit:String?
    var storage_limit:String?
    var amount:String?
    var destination:String?
    var metadata:TezosSimulationContentMetadata?
}

public struct TezosSimulationContentMetadata:Codable {
    var operation_result:TezosSimulationMetadataOperation?
    var internal_operation_results:[TezosSimulationMetadataInternal]?
}

public struct TezosSimulationMetadataOperation:Codable {
    var status:String?
    var balance_updates:[TezosSimulationOperationBalanceUpdate]?
    var consumed_gas:String?
    var consumed_milligas:String?
    var allocated_destination_contract:[String:String]?
    var paid_storage_size_diff:String?
}

public struct TezosSimulationOperationBalanceUpdate:Codable {
    var kind:String?
    var contract:String?
    var change:String?
    var origin:String?
}
// internal_operation_results
public struct TezosSimulationMetadataInternal:Codable {
    var kind:String?
    var source:String?
    var nonce:Int?
    var amount:String?
    var destination:String?
    var result:TezosSimulationMetadataOperation?
}

// MARK: transaction

public struct PreappleOperationResult:Codable {
    var contents:[PreappleOperationContent]?
}

public struct PreappleOperationContent:Codable {
    var metadata:TezosSimulationContentMetadata?
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

