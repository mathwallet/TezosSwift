//
//  RPCURL.swift
//  
//
//  Created by xgblin on 2022/6/9.
//

import Foundation

public protocol RPCURLRequest {
    var parmaters:Encodable? {get}
    var RPCURLString:String {get}
}

public struct GetChainIDURL:RPCURLRequest {
    public var parmaters:Encodable?
    
    let nodeUrl:String
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/chain_id"
    }
}

public struct GetHeadHeader:RPCURLRequest {
    public var parmaters: Encodable?
    
    let nodeUrl:String
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/header"
    }
}

public struct GetHeadHashURL:RPCURLRequest {
    public var parmaters: Encodable?
    
    let nodeUrl:String
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/hash"
    }
}

public struct GetBlockHeadURL:RPCURLRequest {
    public var parmaters: Encodable?
    
    let nodeUrl:String
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head"
    }
}

public struct GetManagerKeyURL:RPCURLRequest {
    public var parmaters: Encodable?
    let nodeUrl:String
    let address:String
    
    init(nodeUrl:String,address:String) {
        self.nodeUrl = nodeUrl
        self.address = address
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/context/contracts/" + address + "/manager_key"
    }
}

public struct GetCounterURL:RPCURLRequest {
    public var parmaters: Encodable?
    
    let nodeUrl:String
    let address:String
    
    init(nodeUrl:String,address:String) {
        self.nodeUrl = nodeUrl
        self.address = address
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/context/contracts/" + address + "/counter"
    }
}

public struct GetNetworkConstantsURL:RPCURLRequest {
    public var parmaters: Encodable?
    
    let nodeUrl:String
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/context/constants"
    }
}

public struct GetBalanceURL:RPCURLRequest {
    public var parmaters: Encodable?
    
    let nodeUrl:String
    let address:String
    
    init(nodeUrl:String,address:String) {
        self.nodeUrl = nodeUrl
        self.address = address
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    }
}

public struct GetNFTURL:RPCURLRequest {
    public var parmaters: Encodable?
    
    let address:String
    let limit:String
    
    init(address:String,limit:String) {
        self.address = address
        self.limit = limit
    }
    
    public var RPCURLString:String {
        return "https://api.tzkt.io/v1/tokens/balances?account=\(address)&sort.desc=balance&limit=\(limit)"
    }
}

public struct RunViewURL:RPCURLRequest {
    public var parmaters:Encodable?
    
    let nodeUrl:String
    public init(nodeUrl:String,input:TezosArg,chainId:String,mode:String = "Readable",mint:String,entrypoint:String) {
        self.nodeUrl = nodeUrl
        self.parmaters = RunViewParmater(unparsing_mode: mode, contract: mint, entrypoint: entrypoint, chain_id: chainId, input: input)
    }
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/helpers/scripts/run_view"
    }
}

public struct RunOperationURL:RPCURLRequest {
    let nodeUrl:String
    public var parmaters:Encodable?
    
    public init(nodeUrl:String,operations:[TezosOperation],metadata:TezosBlockchainMetadata) {
        self.nodeUrl = nodeUrl
        self.parmaters = RunOperationParmater(operation: SignedRunOperationPayload(contents: operations, branch: metadata.blockHash, signature: defultSignature),
                                              chain_id: metadata.chainId!)
    }
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/helpers/scripts/run_operation"
    }
}

public struct ForgeURL:RPCURLRequest {
    let nodeUrl:String
    let headHash:String
    public var parmaters:Encodable?
    
    init(nodeUrl:String,headHash:String,operations:[TezosOperation],branch:String) {
        self.nodeUrl = nodeUrl
        self.headHash = headHash
        self.parmaters = ForgeURLParmaster(contents: operations, branch: branch)
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/" + headHash + "/helpers/forge/operations"
    }
}

public struct PreapplyOperationURL:RPCURLRequest {
    let nodeUrl:String
    let branch:String
    public var parmaters:Encodable?
    
    init(nodeUrl:String,branch:String,operations:[TezosOperation], protocolString: String, signature: String) {
        self.nodeUrl = nodeUrl
        self.branch = branch
        self.parmaters = [SignedOperationPayload(contents: operations, branch: branch, protocol: protocolString, signature: signature)]
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/" + branch + "/helpers/preapply/operations"
    }
}

public struct InjectOperationURL:RPCURLRequest {
    public var parmaters:Encodable?
    
    let nodeUrl:String
    init(nodeUrl:String,sendString:String) {
        self.nodeUrl = nodeUrl
        self.parmaters = sendString
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/injection/operation"
    }
}
