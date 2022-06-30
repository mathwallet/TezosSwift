//
//  RPCURL.swift
//  
//
//  Created by xgblin on 2022/6/9.
//

import Foundation

public protocol RPCURL {
    var RPCURLString:String {get}
}

public struct GetChainIDURL:RPCURL {
    let nodeUrl:String
    
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/chain_id"
    }
}

public struct GetHeadHeader:RPCURL {
    let nodeUrl:String
    
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/header"
    }
}

public struct GetHeadHashURL:RPCURL {
    let nodeUrl:String
    
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/hash"
    }
}

public struct GetBlockHeadURL:RPCURL {
    let nodeUrl:String
    
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head"
    }
}

public struct GetManagerKeyURL:RPCURL {
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

public struct GetCounterURL:RPCURL {
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

public struct GetNetworkConstantsURL:RPCURL {
    let nodeUrl:String
    
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/context/constants"
    }
}

public struct GetBalanceURL:RPCURL {
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

public struct GetNFTURL:RPCURL {
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

public struct RunViewURL:RPCURL {
    let nodeUrl:String
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/helpers/scripts/run_view"
    }
}

public struct RunOperationURL:RPCURL {
    let nodeUrl:String
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/helpers/scripts/run_operation"
    }
}

public struct ForgeURL:RPCURL {
    let nodeUrl:String
    let headHash:String
    init(nodeUrl:String,headHash:String) {
        self.nodeUrl = nodeUrl
        self.headHash = headHash
    }
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/" + headHash + "/helpers/forge/operations"
    }
}

public struct PreapplyOperationURL:RPCURL {
    let nodeUrl:String
    let branch:String
    init(nodeUrl:String,branch:String) {
        self.nodeUrl = nodeUrl
        self.branch = branch
    }
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/" + branch + "/helpers/preapply/operations"
    }
}

public struct InjectOperationURL:RPCURL {
    let nodeUrl:String
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    public var RPCURLString:String {
        return nodeUrl + "/injection/operation"
    }
}
