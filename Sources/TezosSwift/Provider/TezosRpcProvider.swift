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
    
    
//    public func getXTZBalance(address:String,successBlock:@escaping (_ balance:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL: GetBalanceURL(nodeUrl: self.nodeUrl, address: address)) { data in
//            do {
//                let resultString = String(data: data, encoding: .utf8)
//                let string = try JSONDecoder().decode(String.self, from: data)
//                successBlock(string)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//
//    }
    
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
    
//    public func getFa1_2TokenBalancee(address:String,contract:String,successBlock:@escaping (_ balance:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        let p:Parameters = ["unparsing_mode": "Readable",
//                            "contract": contract,
//                            "entrypoint": "getBalance",
//                            "input": [
//                                "string": address
//                            ],
//                            "chain_id": "NetXdQprcVkpaWU"]
//        self.POST(rpcURL: RunViewURL(nodeUrl: self.nodeUrl), parameters: p) { data in
//            do {
//                let result = try JSONDecoder().decode(FA1_2BalanceResult.self, from: data)
//                successBlock(result.balance)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
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
    
//    public func getFa2TokenBalancee(address:String,contract:String,tokenID:String,successBlock:@escaping (_ balance:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        let p:Parameters = [
//            "unparsing_mode": "Readable",
//            "contract": contract,
//            "entrypoint": "balance_of",
//            "chain_id": "NetXdQprcVkpaWU",
//            "input":[
//                [
//                "prim": "Pair",
//                "args":[
//                    [
//                        "string": address
//                    ],[
//                        "int":tokenID
//                    ]
//                ]
//            ]
//            ]
//        ]
//        self.POST(rpcURL: RunViewURL(nodeUrl: self.nodeUrl), parameters: p) { data in
//            do {
//                let result = try! JSONDecoder().decode(FA2BalanceResult.self, from: data)
//                successBlock(result.balance)
//            } catch let e{
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
    public func getNfts(address:String) -> Promise<[TezosNFTResult]> {
        return Promise<[TezosNFTResult]> {seal in
            request(rpcURL: GetNFTURL(address: address, limit:"1000")).done { (results:Array<TezosNFTResult>) in
                seal.fulfill(results)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
//    public func getNfts(address:String,successBlock:@escaping (_ nfts:[TezosNFTResult])-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetNFTURL(address: address, limit:"1000")) { data in
//            do {
//                let nfts = try JSONDecoder().decode(Array<TezosNFTResult>.self, from: data)
//                let filteredNfts = nfts.filter({$0.image.description.count > 0 && Int($0.count) ?? 0 > 0})
//                successBlock(filteredNfts)
//            } catch let e{
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
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
    
//    public func getChainID(successBlock:@escaping (_ chainID:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetChainIDURL(nodeUrl: nodeUrl)) { data in
//            do {
//                let resultString = String(data: data, encoding: .utf8)
//                let string = try JSONDecoder().decode(String.self, from: data)
//                successBlock(string)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    public func getHeadHash() -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetHeadHashURL(nodeUrl: nodeUrl)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func getHeadHash(successBlock:@escaping (_ headHash:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetHeadHashURL(nodeUrl: nodeUrl)) { data in
//            do {
//                let resultString = String(data: data, encoding: .utf8)
//                let string = try JSONDecoder().decode(String.self, from: data)
//                successBlock(string)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
    public func getHeadHeader() -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetHeadHeader(nodeUrl: nodeUrl)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func getHeadHeader(successBlock:@escaping (_ blockHeight:Int)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetHeadHeader(nodeUrl: nodeUrl)) { data in
//            do {
//                let result = try JSONDecoder().decode(GetHeadHeaderResult.self, from: data)
//                successBlock(result.level ?? 0)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }

    public func getNetworkConstants() -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetNetworkConstantsURL(nodeUrl: nodeUrl)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func getNetworkConstants(successBlock:@escaping (_ contents:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetNetworkConstantsURL(nodeUrl: nodeUrl)) { data in
//            do {
//                let resultString = String(data: data, encoding: .utf8)
//                let string = try JSONDecoder().decode(String.self, from: data)
//                successBlock(string)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
    public func getManagerKey(address:String) -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetManagerKeyURL(nodeUrl: nodeUrl,address: address)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func getManagerKey(address:String,successBlock:@escaping (_ managerKey:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetManagerKeyURL(nodeUrl: nodeUrl,address: address)) { data in
//            do {
//                let resultString = String(data: data, encoding: .utf8)
//                let string = try JSONDecoder().decode(String.self, from: data)
//                successBlock(string)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
    public func getCounter(address:String) -> Promise<String> {
        return Promise<String> {seal in
            request(rpcURL: GetCounterURL(nodeUrl: nodeUrl,address: address)).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func getCounter(address:String,successBlock:@escaping (_ counter:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetCounterURL(nodeUrl: nodeUrl,address: address)) { data in
//            do {
//                let resultString = String(data: data, encoding: .utf8)
//                let string = try JSONDecoder().decode(String.self, from: data)
//                successBlock(string)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    public func getBlocksHead() -> Promise<GetChainHeadResult> {
        return Promise<GetChainHeadResult> {seal in
            request(rpcURL: GetBlockHeadURL(nodeUrl: nodeUrl)).done { (result:GetChainHeadResult) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func getBlocksHead(successBlock:@escaping (_ chainHeadResult:GetChainHeadResult)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.GET(rpcURL:GetBlockHeadURL(nodeUrl: nodeUrl)) { data in
//            do {
//                let chainHeadResult = try JSONDecoder().decode(GetChainHeadResult.self, from: data)
//                successBlock(chainHeadResult)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
    public func getConstants()-> Promise<TezosNetworkConstants> {
        return Promise<TezosNetworkConstants> {seal in
            request(rpcURL: GetNetworkConstantsURL(nodeUrl: nodeUrl)).done { (result:TezosNetworkConstants) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func getConstants(successBlock:@escaping (_ constants:TezosNetworkConstants)-> Void,failure:@escaping (_ error:Error)-> Void){
//        self.GET(rpcURL:GetNetworkConstantsURL(nodeUrl: self.nodeUrl)) { data in
//            do {
//                let constants = try JSONDecoder().decode(TezosNetworkConstants.self, from: data)
//                successBlock(constants)
//            } catch let e {
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
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
//    public func getMetadata(address:String,successBlock:@escaping (_ metadata:TezosBlockchainMetadata)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        var counterNum:Int = 0
//        var blockChainHead = GetChainHeadResult()
//        var managerkeyString:String = ""
//        var networkConstants = TezosNetworkConstants()
//
//        let globalQueue = DispatchQueue.global()
//        let group = DispatchGroup()
//        group.enter()
//        globalQueue.async {
//            self.getCounter(address: address) { counter in
//                counterNum = Int(counter)! + 1
//                group.leave()
//            } failure: { error in
//                failure(error)
//                group.leave()
//            }
//
//        }
//
//        group.enter()
//        globalQueue.async {
//            self.getBlocksHead { chainHeadResult in
//                blockChainHead = chainHeadResult
//                group.leave()
//            } failure: { error in
//                failure(error)
//                group.leave()
//            }
//
//        }
//
//        group.enter()
//        globalQueue.async {
//            self.getManagerKey(address: address) { managerKey in
//                managerkeyString = managerKey
//                group.leave()
//            } failure: { error in
//                failure(error)
//                group.leave()
//            }
//
//        }
//
//        group.enter()
//        globalQueue.async {
//            self.getConstants{ constants in
//                networkConstants = constants
//                group.leave()
//            } failure: { error in
//                failure(error)
//                group.leave()
//            }
//        }
//
//        group.notify(queue: globalQueue) {
//            let metadata = TezosBlockchainMetadata(blockHash: blockChainHead.hash ?? "", protocolString: blockChainHead.protocolString ?? "", counter: counterNum, key:managerkeyString , constants: networkConstants)
//            successBlock(metadata)
//        }
//    }
    
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
     
//    public func getSimulationResponse(metadata:TezosBlockchainMetadata,operation:Tezos.Operation,successBlock:@escaping (_ response:SimulationResponse)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        guard let operationPayload = TezosOperationUtil.operationPayload(operation: operation) else {
//            failure(TezosRpcProviderError.server(message: "Operation error"))
//            return
//        }
//        let p:Parameters = [
//            "operation":[
//                "branch":metadata.blockHash,
//                "signature":"edsigtkpiSSschcaCt9pUVrpNPf7TTcgvgDEDD6NCEHMy8NNQJCGnMfLZzYoQj74yLjo9wx6MPVV29CvVzgi7qEcEUok3k7AuMg",
//                "contents":[
//                    operationPayload
//                ]
//            ],
//            "chain_id":metadata.chainId ?? "NetXdQprcVkpaWU"
//        ]
//        self.POST(rpcURL: RunOperationURL(nodeUrl: self.nodeUrl), parameters: p) { data in
//            do {
//                let result = try JSONDecoder().decode(TezosSimulationResult.self, from: data)
//                let parser = TezosSimulationResponseParser(constants: metadata.constants)
//                guard let content = result.contents,let responseResult = parser.parseSimulation(contents: content) else {
//                    failure(TezosRpcProviderError.server(message: "Parameter error"))
//                    return
//                }
//                successBlock(responseResult)
//
////                let json = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
////                guard let dic = json as? [String:Any] else {
////                    failure(TezosRpcProviderError.server(message: "Parameter error"))
////                    return
////                }
////                let parser = TezosSimulationResponseParser(constants: metadata.constants)
////                guard let responseResult = parser.parseSimulation(jsonDic: dic) else {
////                    failure(TezosRpcProviderError.server(message: "Data error"))
////                    return
////                }
//                successBlock(responseResult)
//            } catch let e{
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
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
    
//    public func forge(branch:String,operation:Tezos.Operation,successBlock:@escaping (_ forgeResult:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        guard let operationPayload = TezosOperationUtil.operationPayload(operation: operation) else {
//            failure(TezosRpcProviderError.server(message: "forge error"))
//            return
//        }
//        self.getHeadHash { headHash in
//            let p:Parameters = ["branch":branch,
//                                "contents": [
//                                    operationPayload
//                                            ]
//            ]
//            self.POST(rpcURL: ForgeURL(nodeUrl: self.nodeUrl, headHash: headHash), parameters: p) { data in
//                do {
//                    let resultString = String(data: data, encoding: .utf8)
//                    let result = try JSONDecoder().decode(String.self, from:data)
//                    successBlock(result)
//                } catch let e{
//                    failure(e)
//                }
//            } failure: { error in
//                failure(error)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    public func preapplyOperation(operationDictionary:[String:Any],branch:String) -> Promise<Bool> {
        return Promise<Bool> {seal in
            request(rpcURL:  PreapplyOperationURL(nodeUrl:nodeUrl, branch: branch), method: .post, parameters: [operationDictionary].asParameters()).done { (results:Array<PreappleOperationResult>) in
                let isSuccess = TezosPreapplyResponseParser.parse(results: results)
                seal.fulfill(isSuccess)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
//    public func preapplyOperation(operationDictionary:[String:Any],branch:String,successBlock:@escaping (_ isSuccess:Bool)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.POST(rpcURL: PreapplyOperationURL(nodeUrl: self.nodeUrl, branch: branch),encoding: ArrayEncoding.default, parameters: [operationDictionary].asParameters()) { data in
//            do {
//                let json = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
//                let jsonArray = json as! Array<[String:Any]>
//                let isSuccess = TezosPreapplyResponseParser.parse(jsonArray: jsonArray)
//                successBlock(isSuccess)
//            } catch let e{
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    public func injectOperation(signedString:String) -> Promise<String> {
        return Promise<String> { seal in
            request(rpcURL: InjectOperationURL(nodeUrl:nodeUrl),parameters: signedString.asParameters()).done { (result:String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
//    public func injectOperation(signedString:String,successBlock:@escaping (_ resultString:String)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        self.POST(rpcURL:InjectOperationURL(nodeUrl: self.nodeUrl),encoding: StringEncoding.default, parameters: signedString.asParameters()) { data in
//            do {
//                let resultString = String(data: data, encoding: .utf8)
//                let result = try JSONDecoder().decode(String.self, from:data)
//                successBlock(result)
//            } catch let e{
//                failure(e)
//            }
//        } failure: { error in
//            failure(error)
//        }
//    }
    
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
    
//    public func preapplyTransaction(transaction:TezosTransaction,successBlock:@escaping (_ isSuccess:Bool)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        transaction.operations.forEach { operation in
//            transaction.resetOperation()
//            // calculate fee
//            self.calculateFees(operation: operation,metadata: transaction.metadata) { haveFeeOperation in
//                // create actual trading operation
//                transaction.addOperation(operation: haveFeeOperation)
//                // forge transaction
//                self.forge(branch: transaction.branch, operation: haveFeeOperation) { forgeResult in
//                    transaction.forgeString = forgeResult
//                    successBlock(true)
//                } failure: { error in
//                    failure(error)
//                }
//            } failure: { error in
//                failure(error)
//            }
//        }
//    }
    
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
    
//    func calculateFees(operation:Tezos.Operation,metadata:TezosBlockchainMetadata,successBlock:@escaping (_ haveFeeOperation:Tezos.Operation)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        switch operation{
//        case .transaction(_),.reveal(_),.origination(_),.delegation(_):
//            self.getSimulationResponse(metadata: metadata, operation: operation) { response in
//                let service = TezosFeeEstimatorService()
//                self.forge(branch:metadata.blockHash ,operation: operation) { forgeResult in
//                    let haveFeeOperation = service.calculateFeesAndCreatOperation(response: response, operation: operation, operationSize: service.getForgedOperationsSize(forgeResult: forgeResult))
//                    successBlock(haveFeeOperation)
//                } failure: { error in
//                    failure(error)
//                }
//            } failure: { error in
//                failure(error)
//            }
//        default:
//            successBlock(operation)
//        }
//    }
}

extension TezosRpcProvider {
//    func GET(rpcURL:RPCURL,encoding: ParameterEncoding = JSONEncoding.default, successBlock:@escaping (_ data:Data)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        AF.request(rpcURL.RPCURLString, method: .get, encoding: encoding, headers: nil).responseData { response in
//            switch response.result {
//            case .success(let data):
//                successBlock(data)
//            case let .failure(e):
//                failure(e)
//            }
//        }
//    }
    
//    func request<T:Codable>(rpcURL:RPCURL,method: HTTPMethod = .get,parameters:T? = nil,encoder: ParameterEncoder = JSONParameterEncoder.default) -> Promise<T> {
//        return Promise { seal in
//            AF.request(rpcURL.RPCURLString, method: method,parameters: parameters,encoder: encoder, headers: nil).responseData { response in
//                switch response.result {
//                case .success(let data):
//                    do {
//                        let result = try JSONDecoder().decode(T.self, from: data)
//                        seal.fulfill(result)
//                    } catch let e {
//                        seal.reject(e)
//                    }
//                case let .failure(e):
//                    seal.reject(e)
//                }
//            }
//        }
//    }
    
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
    
//    func POST(rpcURL:RPCURL,encoding: ParameterEncoding = JSONEncoding.default,parameters:Parameters,successBlock:@escaping (_ data:Data)-> Void,failure:@escaping (_ error:Error)-> Void) {
//        AF.request(rpcURL.RPCURLString, method: .post, parameters: parameters, encoding:encoding , headers: nil).responseData { response in
//            switch response.result {
//            case .success(let data):
//                successBlock(data)
//            case let .failure(e):
//                failure(e)
//            }
//        }
//    }
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

