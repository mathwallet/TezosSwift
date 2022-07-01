//
//  TezosRpcProvider.swift
//  
//
//  Created by xgblin on 2022/6/9.
//

import Foundation
import Alamofire
import CryptoSwift

public struct TezosRpcProvider {
    
    public var nodeUrl:String
    public init(nodeUrl: String) {
        self.nodeUrl = nodeUrl
    }
    
    public func getXTZBalance(address:String,successBlock:@escaping (_ balance:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL: GetBalanceURL(nodeUrl: self.nodeUrl, address: address)) { data in
            do {
                let string = try JSONDecoder().decode(String.self, from: data)
                successBlock(string)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }

    }
    
    public func getFa1_2TokenBalancee(address:String,contract:String,successBlock:@escaping (_ balance:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        let p:Parameters = ["unparsing_mode": "Readable",
                            "contract": contract,
                            "entrypoint": "getBalance",
                            "input": [
                                "string": address
                            ],
                            "chain_id": "NetXdQprcVkpaWU"]
        self.POST(rpcURL: RunViewURL(nodeUrl: self.nodeUrl), parameters: p) { data in
            do {
                let result = try JSONDecoder().decode(GetFA1_2TokenBalanceResult.self, from: data)
                successBlock(result.balance())
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getFa2TokenBalancee(address:String,contract:String,tokenID:String,successBlock:@escaping (_ balance:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        let p:Parameters = [
            "unparsing_mode": "Readable",
            "contract": contract,
            "entrypoint": "balance_of",
            "chain_id": "NetXdQprcVkpaWU",
            "input":[
                [
                "prim": "Pair",
                "args":[
                    [
                        "string": address
                    ],[
                        "int":tokenID
                    ]
                ]
            ]
            ]
        ]
        self.POST(rpcURL: RunViewURL(nodeUrl: self.nodeUrl), parameters: p) { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
                let dic = json as! Dictionary<String,Any>
                guard let dataArray = dic["data"] as? Array<Dictionary<String,Any>>, let dataResult = dataArray.first, let args = dataResult["args"] as? Array<Dictionary<String,Any>>, let balance = args[1]["int"] as? String else {
                    failure(TezosRpcProviderError.server(message: "data error"))
                    return
                }
                successBlock(balance)
            } catch let e{
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getNfts(address:String,successBlock:@escaping (_ nfts:[TezosNFTResult])-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetNFTURL(address: address, limit:"1000")) { data in
            do {
                let nfts = try JSONDecoder().decode(Array<TezosNFTResult>.self, from: data)
                let filteredNfts = nfts.filter({$0.image.description.count > 0 && Int($0.count) ?? 0 > 0})
                successBlock(filteredNfts)
            } catch let e{
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
}

// MARK: Base Data
extension  TezosRpcProvider {
    public func getChainID(successBlock:@escaping (_ chainID:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetChainIDURL(nodeUrl: nodeUrl)) { data in
            do {
                let string = try JSONDecoder().decode(String.self, from: data)
                successBlock(string)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getHeadHash(successBlock:@escaping (_ headHash:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetHeadHashURL(nodeUrl: nodeUrl)) { data in
            do {
                let string = try JSONDecoder().decode(String.self, from: data)
                successBlock(string)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getHeadHeader(successBlock:@escaping (_ blockHeight:Int)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetHeadHeader(nodeUrl: nodeUrl)) { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
                let dic = json as! Dictionary<String,Any>
                guard let height = dic["level"] as? Int else {
                    failure(TezosRpcProviderError.server(message: "数据错误"))
                    return
                }
                successBlock(height)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }

    
    public func getNetworkConstants(successBlock:@escaping (_ contents:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetNetworkConstantsURL(nodeUrl: nodeUrl)) { data in
            do {
                let string = try JSONDecoder().decode(String.self, from: data)
                successBlock(string)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getManagerKey(address:String,successBlock:@escaping (_ managerKey:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetManagerKeyURL(nodeUrl: nodeUrl,address: address)) { data in
            do {
                let string = try JSONDecoder().decode(String.self, from: data)
                successBlock(string)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getCounter(address:String,successBlock:@escaping (_ counter:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetCounterURL(nodeUrl: nodeUrl,address: address)) { data in
            do {
                let string = try JSONDecoder().decode(String.self, from: data)
                successBlock(string)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getBlocksHead(successBlock:@escaping (_ chainHeadResult:GetChainHeadResult)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.GET(rpcURL:GetBlockHeadURL(nodeUrl: nodeUrl)) { data in
            do {
                let chainHeadResult = try JSONDecoder().decode(GetChainHeadResult.self, from: data)
                successBlock(chainHeadResult)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getConstants(successBlock:@escaping (_ constants:TezosNetworkConstants)-> Void,failure:@escaping (_ error:Error)-> Void){
        self.GET(rpcURL:GetNetworkConstantsURL(nodeUrl: self.nodeUrl)) { data in
            do {
                let constants = try JSONDecoder().decode(TezosNetworkConstants.self, from: data)
                successBlock(constants)
            } catch let e {
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func getMetadata(address:String,successBlock:@escaping (_ metadata:TezosBlockchainMetadata)-> Void,failure:@escaping (_ error:Error)-> Void) {
        var counterNum:Int = 0
        var blockChainHead = GetChainHeadResult()
        var managerkeyString:String = ""
        var networkConstants = TezosNetworkConstants()
        
        let globalQueue = DispatchQueue.global()
        let group = DispatchGroup()
        group.enter()
        globalQueue.async {
            self.getCounter(address: address) { counter in
                counterNum = Int(counter)! + 1
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }

        }
        
        group.enter()
        globalQueue.async {
            self.getBlocksHead { chainHeadResult in
                blockChainHead = chainHeadResult
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }

        }
        
        group.enter()
        globalQueue.async {
            self.getManagerKey(address: address) { managerKey in
                managerkeyString = managerKey
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }

        }
        
        group.enter()
        globalQueue.async {
            self.getConstants{ constants in
                networkConstants = constants
                group.leave()
            } failure: { error in
                failure(error)
                group.leave()
            }
        }
        
        group.notify(queue: globalQueue) {
            let metadata = TezosBlockchainMetadata(blockHash: blockChainHead.hash ?? "", protocolString: blockChainHead.protocolString ?? "", counter: counterNum, key:managerkeyString , constants: networkConstants)
            successBlock(metadata)
        }
    }
    
}

// MARK: transaction Base
extension  TezosRpcProvider {
    public func forge(branch:String,operation:TezosBaseOperation,successBlock:@escaping (_ forgeResult:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.getHeadHash { headHash in
            let p:Parameters = ["branch":branch,
                                "contents": [operation.payload()]
            ]
            self.POST(rpcURL: ForgeURL(nodeUrl: self.nodeUrl, headHash: headHash), parameters: p) { data in
                do {
                    let result = try JSONDecoder().decode(String.self, from:data)
                    successBlock(result)
                } catch let e{
                    failure(e)
                }
            } failure: { error in
                failure(error)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func preapplyOperation(operationDictionary:Dictionary<String,Any>,branch:String,successBlock:@escaping (_ isSuccess:Bool)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.POST(rpcURL: PreapplyOperationURL(nodeUrl: self.nodeUrl, branch: branch),encoding: ArrayEncoding.default, parameters: [operationDictionary].asParameters()) { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
                let jsonArray = json as! Array<Dictionary<String,Any>>
                let isSuccess = TezosPreapplyResponseParser.parse(jsonArray: jsonArray)
                successBlock(isSuccess)
            } catch let e{
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    public func injectOperation(signedString:String,successBlock:@escaping (_ resultString:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
        self.POST(rpcURL:InjectOperationURL(nodeUrl: self.nodeUrl),encoding: StringEncoding.default, parameters: signedString.asParameters()) { data in
            do {
                let result = try JSONDecoder().decode(String.self, from:data)
                successBlock(result)
            } catch let e{
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
}

// MARK: Pretreatment transaction
extension  TezosRpcProvider {
    
    public func getSimulationResponse(metadata:TezosBlockchainMetadata,operation:TezosBaseOperation,successBlock:@escaping (_ response:SimulationResponse)-> Void,failure:@escaping (_ error:Error)-> Void) {
        let p:Parameters = [
            "operation":[
                "branch":metadata.blockHash,
                "signature":"edsigtkpiSSschcaCt9pUVrpNPf7TTcgvgDEDD6NCEHMy8NNQJCGnMfLZzYoQj74yLjo9wx6MPVV29CvVzgi7qEcEUok3k7AuMg",
                "contents":[operation.payload()]
            ],
            "chain_id":metadata.chainId ?? "NetXdQprcVkpaWU"
        ]
        self.POST(rpcURL: RunOperationURL(nodeUrl: self.nodeUrl), parameters: p) { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
                let dic = json as! Dictionary<String,Any>
                let parser = TezosSimulationResponseParser(constants: metadata.constants)
                let responseResult = parser.parseSimulation(jsonDic: dic)
                successBlock(responseResult)
            } catch let e{
                failure(e)
            }
        } failure: { error in
            failure(error)
        }
    }
    
//    preapplyTransaction
    public func preapplyTransaction(transaction:TezosTransaction,successBlock:@escaping (_ isSuccess:Bool)-> Void,failure:@escaping (_ error:Error)-> Void) {
        transaction.resetOperation()
        transaction.operations.forEach { operation in
            // calculate fee
            transaction.calculateFees(operation: operation) { haveFeeOperation in
                // create actual trading operation
                transaction.addOperation(operation: haveFeeOperation)
                // forge transaction
                self.forge(branch: transaction.branch, operation: haveFeeOperation) { forgeResult in
                    transaction.forgeString = forgeResult
                    successBlock(true)
                } failure: { error in
                    failure(error)
                }
            } failure: { error in
                failure(error)
            }
        }
    }
    
}


extension TezosRpcProvider {
    func GET(rpcURL:RPCURL,encoding: ParameterEncoding = JSONEncoding.default, successBlock:@escaping (_ data:Data)-> Void,failure:@escaping (_ error:Error)-> Void) {
        AF.request(rpcURL.RPCURLString, method: .get, encoding: encoding, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                successBlock(data)
            case let .failure(e):
                failure(e)
            }
        }
    }
    
    func POST(rpcURL:RPCURL,encoding: ParameterEncoding = JSONEncoding.default,parameters:Parameters,successBlock:@escaping (_ data:Data)-> Void,failure:@escaping (_ error:Error)-> Void) {
        AF.request(rpcURL.RPCURLString, method: .post, parameters: parameters, encoding:encoding , headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                successBlock(data)
            case let .failure(e):
                failure(e)
            }
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

