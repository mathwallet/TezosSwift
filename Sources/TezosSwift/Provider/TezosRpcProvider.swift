//
//  File.swift
//  
//
//  Created by 薛跃杰 on 2022/6/9.
//

import Foundation
import Alamofire

public struct TezosRpcProvider {
    
    public var nodeUrl:String
    public init(nodeUrl: String) {
        self.nodeUrl = nodeUrl
    }
    
    public func getTokenBalance(address:String,contractAddress:String,successBlock:@escaping (_ balance:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        var chain_id:String = ""
        var counterSting:String = ""
        var headHashString:String = ""
        
        let globalQueue = DispatchQueue.global()
        let group = DispatchGroup()
        group.enter()
        globalQueue.async {
            self.getChainID { chainID in
                chain_id = chainID
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }
        }
        group.enter()
        globalQueue.async {
            self.getCounter(address: address) { counter in
                counterSting = counter
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }

        }
        group.enter()
        globalQueue.async {
            self.getHeadHash{ headHash in
                headHashString = headHash
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }

        }
        group.notify(queue: globalQueue) {
            let p:Parameters = ["chain_id": chain_id,
                                "operation": GetTokenBalanceOperation(address: address, tokenContractAddress: contractAddress, counter: counterSting, branch: headHashString).toJsonDic() as Any
            ]
            self.POST(rpcURL: RunOperationURL(nodeUrl: nodeUrl), parameters: p) { data in
                do {
                    let result = try JSONDecoder().decode(Array<TezosTokenBalanceResult>.self, from: data)
                    guard let balance = result[0].expected else {
                        failure(TezosRpcProviderError.unknown)
                        return
                    }
                    successBlock(balance)
                } catch let e {
                    failure(e)
                }
            } failure: { error in
                failure(error)
            }
        }
    }
}

extension  TezosRpcProvider {
    func GET(rpcURL:RPCURL,successBlock:@escaping (_ data:Data)-> Void,failure:@escaping (_ error:Error)-> Void) {
        AF.request(rpcURL.RPCURLString, method: .post, encoding: JSONEncoding.default, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                successBlock(data)
            case let .failure(e):
                failure(e)
            }
        }
    }
    
    func POST(rpcURL:RPCURL,parameters:Parameters,successBlock:@escaping (_ data:Data)-> Void,failure:@escaping (_ error:Error)-> Void) {
        AF.request(rpcURL.RPCURLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                successBlock(data)
            case let .failure(e):
                failure(e)
            }
        }
    }
}

extension  TezosRpcProvider {
    public func getChainID(successBlock:@escaping (_ chainID:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetChainIDURL(nodeUrl: nodeUrl)) { data in
            successBlock(String(data: data, encoding: .utf8) ?? "")
        } failure: { error in
            failure(error)
        }
    }
    
    public func getHeadHash(successBlock:@escaping (_ headHash:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetHeadHashURL(nodeUrl: nodeUrl)) { data in
            successBlock(String(data: data, encoding: .utf8) ?? "")
        } failure: { error in
            failure(error)
        }
    }
    
    public func getNetworkConstants(successBlock:@escaping (_ contents:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetNetworkConstantsURL(nodeUrl: nodeUrl)) { data in
            successBlock(String(data: data, encoding: .utf8) ?? "")
        } failure: { error in
            failure(error)
        }
    }
    
    public func getManagerKey(address:String,successBlock:@escaping (_ managerKey:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetManagerKeyURL(nodeUrl: nodeUrl,address: address)) { data in
            successBlock(String(data: data, encoding: .utf8) ?? "")
        } failure: { error in
            failure(error)
        }
    }
    
    public func getCounter(address:String,successBlock:@escaping (_ counter:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetCounterURL(nodeUrl: nodeUrl,address: address)) { data in
            successBlock(String(data: data, encoding: .utf8) ?? "")
        } failure: { error in
            failure(error)
        }
    }
}

public enum TezosRpcProviderError: LocalizedError {
    case unknown
    case server(message: String)
    public var errorDescription: String? {
        switch self {
        case .server(let message):
            return message
        default:
            return "Unknown error"
        }
    }
}
