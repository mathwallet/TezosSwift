//
//  TezosSimulationResponseParser.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/21.
//

import Foundation

public struct TezosSimulationResponseParser {
    let constants:TezosNetworkConstants
    init (constants:TezosNetworkConstants) {
        self.constants = constants
    }
    
    public func parseSimulation(jsonDic:Dictionary<String,Any>) -> SimulationResponse {
        var simulations = [SimulatedFees]()
        if let contents = jsonDic["contents"] as? Array<Dictionary<String,Any>> {
            contents.forEach { content in
                if let type = content["kind"] as? String,let metadata = content["metadata"] as? Dictionary<String,Any>,let results = metadata["operation_result"] as? Dictionary<String,Any> {
                    var operationExtraFees = [ExtraFee]()
                    if let allocationFee = parseAllocationFee(results: results) {
                        operationExtraFees.append(allocationFee)
                    }
                    
                    if let burnFee = parseBurnFee(results: results) {
                        operationExtraFees.append(burnFee)
                    }
                    
                    var consumedGas = Int((results["consumed_gas"] as? String) ?? "0")  ?? 0
                    var consumedStorage = Int((results["paid_storage_size_diff"] as? String) ?? "0") ?? 0
                    if let internalResults = metadata["internal_operation_results"] as? Array<Dictionary<String,Any>> {
                        internalResults.forEach({ internalResult in
                            if let parsedResult = parseInternalOperationResult(internalResult: internalResult) {
                                consumedGas += parsedResult.consumedGas
                                consumedStorage += parsedResult.consumedStorage
                                operationExtraFees += parsedResult.extraFees
                            }
                        })
                    }
                    simulations.append(SimulatedFees(type: type, extraFees: operationExtraFees, consumedGas: consumedGas, consumedStorage: consumedStorage))
                }
            }
            
        }
        return SimulationResponse(simulations: simulations)
    }
    
    private func parseAllocationFee(results: Dictionary<String,Any>) -> ExtraFee? {
        if let _ = results["allocated_destination_contract"] as? Dictionary<String,Any>,let updates = results["balance_updates"] as? Array<Any> {
            if updates.count > 2 {
                if let update = updates[2] as? Dictionary<String,String>, let varue = update["change"],let fee = Int(varue.replacingOccurrences(of: "-", with: "")) {
                    return ExtraFee(fee: fee)
                }
            }
        }
        return nil
    }
    
    private func parseBurnFee(results: Dictionary<String,Any>) -> ExtraFee? {
        if let sizeDiffString = results["paid_storage_size_diff"] as? String,let sizeDiff = Int(sizeDiffString) {
            if sizeDiff > 0 {
                let burn = sizeDiff * (Int(constants.cost_per_byte!) ?? 0)
                return ExtraFee(fee: burn)
            }
        }
        return nil
    }
    
    private func parseInternalOperationResult(internalResult:Dictionary<String,Any>) -> InternalOperationResult? {
        if let result  = internalResult["result"] as? Dictionary<String,Any>,let internalConsumedGasStr = result["consumed_gas"] as? String,let internalConsumedStorageStr = result["paid_storage_size_diff"] as? String {
            let internalConsumedGas = Int(internalConsumedGasStr) ?? 0
            let internalConsumedStorage = Int(internalConsumedStorageStr) ?? 0
            var extraFees = [ExtraFee]()
            if let allocationFee = parseAllocationFee(results: result) {
                extraFees.append(allocationFee)
            }
            
            if let burnFee = parseBurnFee(results: result) {
                extraFees.append(burnFee)
            }
            
            let moreResult = internalResult["result"] as! Dictionary<String,Any>
            let statusString = moreResult["status"] as! String
            let status = OperationResultStatus.get(status: statusString)
            return InternalOperationResult(consumedGas: internalConsumedGas,consumedStorage: internalConsumedStorage,extraFees: extraFees,status: status
            )
        }
        return nil
    }
}

private struct InternalOperationResult{
    let consumedGas: Int
    let consumedStorage: Int
    let extraFees: [ExtraFee]
    let status: OperationResultStatus
}


enum OperationResultStatus {
    case FAILED
    case BACKTRACKED
    case SKIPPED
    case SUCCESS
    case APPLIED
    case UNKNOWN
    
    static func get(status: String?) -> OperationResultStatus {
        let found = status == "failed"
        return found ? .FAILED : .UNKNOWN
    }
}
