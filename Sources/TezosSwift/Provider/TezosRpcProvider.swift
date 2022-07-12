//
//  TezosRpcProvider.swift
//  
//
//  Created by xgblin on 2022/6/9.
//

import Foundation
import Alamofire
import PromiseKit
import CryptoSwift
import BeaconBlockchainTezos

public struct TezosRpcProvider {
    
    public var nodeUrl:String
    public init(nodeUrl: String) {
        self.nodeUrl = nodeUrl
    }
    
    public func getXTZBalance(address:String) -> Promise<String> {
        return Promise<String> { seal in
            request(rpcURL: GetBalanceURL(nodeUrl: self.nodeUrl, address: address)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getFa1_2TokenBalancee(address:String,contract:String) -> Promise<String> {
        return Promise { seal in
            let p:Parameters = ["unparsing_mode": "Readable",
                                "contract": contract,
                                "entrypoint": "getBalance",
                                "input": [
                                    "string": address
                                ],
                                "chain_id": "NetXdQprcVkpaWU"]
            request(rpcURL: RunViewURL(nodeUrl: self.nodeUrl), method: .post, parameters: p).done { (result:FA1_2BalanceResult) in
                seal.fulfill(result.balance)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getFa2TokenBalancee(address:String,contract:String,tokenID:String)-> Promise<String> {
        return Promise<String> { seal in
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
            request(rpcURL: RunViewURL(nodeUrl: self.nodeUrl), method: .post, parameters: p).done { (result:FA2BalanceResult) in
                seal.fulfill(result.balance)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getNfts(address:String) -> Promise<[TezosNFTResult]> {
        return Promise<[TezosNFTResult]> {seal in
            request(rpcURL: GetNFTURL(address: address, limit:"1000")).done { (results:Array<TezosNFTResult>) in
                seal.fulfill(results)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}

// MARK: Base Data
extension  TezosRpcProvider {
    public func getChainID() -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetChainIDURL(nodeUrl: nodeUrl)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getHeadHash() -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetHeadHashURL(nodeUrl: nodeUrl)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getHeadHeader() -> Promise<Int> {
        return Promise<Int> {seal in
            request(rpcURL: GetHeadHeader(nodeUrl: nodeUrl)).done { (result:GetHeadHeaderResult) in
                seal.fulfill(result.level ?? 0)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    public func getNetworkConstants() -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetNetworkConstantsURL(nodeUrl: nodeUrl)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getManagerKey(address:String) -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetManagerKeyURL(nodeUrl: nodeUrl,address: address)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getCounter(address:String) -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetCounterURL(nodeUrl: nodeUrl,address: address)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getBlocksHead() -> Promise<GetChainHeadResult> {
        return Promise<GetChainHeadResult> {seal in
            request(rpcURL: GetBlockHeadURL(nodeUrl: nodeUrl)).done { (result:GetChainHeadResult) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getConstants()-> Promise<TezosNetworkConstants> {
        return Promise<TezosNetworkConstants> {seal in
            request(rpcURL: GetNetworkConstantsURL(nodeUrl: nodeUrl)).done { (result:TezosNetworkConstants) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getMetadata(address:String) -> Promise<TezosBlockchainMetadata> {
        return Promise<TezosBlockchainMetadata> {seal in
            firstly {
                when(fulfilled:
                    getCounter(address: address),
                     getBlocksHead(),
                     getManagerKey(address: address),
                     getConstants()
                )
            }.done { (counter, blocksHead, managerKey, constants) in
                seal.fulfill(TezosBlockchainMetadata(blockHash: blocksHead.hash ?? "", protocolString: blocksHead.protocolString ?? "", counter: Int(counter) ?? 0 + 1, key:managerKey, constants: constants))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getSimulationResponse(metadata:TezosBlockchainMetadata,operation:Tezos.Operation) -> Promise<SimulationResponse> {
        return Promise<SimulationResponse> { seal in
            if let operationPayload = TezosOperationUtil.operationPayload(operation: operation){
                let p:Parameters = [
                    "operation":[
                        "branch":metadata.blockHash,
                        "signature":"edsigtkpiSSschcaCt9pUVrpNPf7TTcgvgDEDD6NCEHMy8NNQJCGnMfLZzYoQj74yLjo9wx6MPVV29CvVzgi7qEcEUok3k7AuMg",
                        "contents":[
                            operationPayload
                        ]
                    ],
                    "chain_id":metadata.chainId ?? "NetXdQprcVkpaWU"
                ]
                request(rpcURL: RunOperationURL(nodeUrl:nodeUrl), method: .post, parameters: p).done { (result:TezosSimulationResult) in
                    let parser = TezosSimulationResponseParser(constants: metadata.constants)
                    if let content = result.contents,let response = parser.parseSimulation(contents: content) {
                        seal.fulfill(response)
                    }else {
                        seal.reject(TezosRpcProviderError.server(message: "Parameter error"))
                    }
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                seal.reject(TezosRpcProviderError.server(message: "Operation error"))
            }
        }
    }
}

// MARK: transaction
extension  TezosRpcProvider {
    
    public func forge(branch:String,operation:Tezos.Operation) -> Promise<String> {
        return Promise<String> {seal in
            if let operationPayload = TezosOperationUtil.operationPayload(operation: operation){
                let p:Parameters = ["branch":branch,
                                    "contents": [
                                        operationPayload
                                    ]
                ]
                getHeadHash().then{ (headHash:String) -> Promise<String> in
                    return request(rpcURL: ForgeURL(nodeUrl: nodeUrl, headHash: headHash), method: .post, parameters: p)
                }.done { forgeString in
                    seal.fulfill(forgeString)
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                seal.reject(TezosRpcProviderError.server(message: "forge error"))
            }
        }
    }
    
    public func preapplyOperation(operationDictionary:[String:Any],branch:String) -> Promise<Bool> {
        return Promise<Bool> {seal in
            request(rpcURL: PreapplyOperationURL(nodeUrl:nodeUrl, branch: branch), method: .post,encoding: ArrayEncoding.default, parameters: [operationDictionary].asParameters()).done { (results:Array<PreappleOperationResult>) in
                let isSuccess = TezosPreapplyResponseParser.parse(results: results)
                seal.fulfill(isSuccess)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func injectOperation(signedString:String) -> Promise<String> {
        return Promise<String> { seal in
            request(rpcURL: InjectOperationURL(nodeUrl:nodeUrl),encoding: StringEncoding.default, parameters: signedString.asParameters()).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
}

// MARK: preapplyTransaction
extension TezosRpcProvider {
    
    public func preapplyTransaction(transaction:TezosTransaction) -> Promise<Bool> {
        return Promise<Bool> {seal in
            transaction.operations.forEach { operation in
                transaction.resetOperation()
                calculateFees(operation: operation, metadata: transaction.metadata).then { havefeeOperation -> Promise< String> in
                    return forge(branch: transaction.branch, operation: havefeeOperation)
                }.done { forgeResult in
                    transaction.forgeString = forgeResult
                    seal.fulfill(true)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
    
    func calculateFees(operation:Tezos.Operation,metadata:TezosBlockchainMetadata) -> Promise<Tezos.Operation> {
        return Promise<Tezos.Operation> {seal in
            switch operation{
            case .transaction(_),.reveal(_),.origination(_),.delegation(_):
                firstly {
                    when(fulfilled:
                            getSimulationResponse(metadata: metadata, operation: operation),
                         forge(branch: metadata.blockHash, operation: operation)
                    )
                }.done { (response, forgeResult) in
                    let service = TezosFeeEstimatorService()
                    let haveFeeOperation = service.calculateFeesAndCreatOperation(response: response, operation: operation, operationSize: service.getForgedOperationsSize(forgeResult: forgeResult))
                    seal.fulfill(haveFeeOperation)
                }.catch { error in
                    seal.reject(error)
                }
            default:
                seal.fulfill(operation)
            }
        }
    }
}

extension TezosRpcProvider {
    
    func request<T:Codable>(rpcURL:RPCURL,method: HTTPMethod = .get,encoding: ParameterEncoding = JSONEncoding.default,parameters:Parameters? = nil) -> Promise<T> {
        return Promise { seal in
            AF.request(rpcURL.RPCURLString, method: method, parameters: parameters, encoding: encoding).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        seal.fulfill(result)
                    } catch let e {
                        seal.reject(e)
                    }
                case let .failure(e):
                    seal.reject(e)
                }
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

