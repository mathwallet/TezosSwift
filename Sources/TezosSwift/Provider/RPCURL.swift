//
//  File.swift
//  
//
//  Created by 薛跃杰 on 2022/6/9.
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

public struct GetHeadHashURL:RPCURL {
    let nodeUrl:String
    
    init(nodeUrl:String) {
        self.nodeUrl = nodeUrl
    }
    
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/hash"
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

public struct RunOperationURL:RPCURL {
    let nodeUrl:String
    public var RPCURLString:String {
        return nodeUrl + "/chains/main/blocks/head/helpers/scripts/run_operation"
    }
}
