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
    
    public func parseSimulation(contents:[TezosSimulationContent]) -> SimulationResponse? {
        var simulations = [SimulatedFees]()
        for content in contents {
            guard let type = content.kind,
                  let metadata = content.metadata,
                  let results = metadata.operation_result,
                  let status = results.status,
                  OperationResultStatus.get(status: status) != .FAILED else {
                return nil
            }
            var operationExtraFees = ExtraFees()
            if let allocationFee = parseAllocationFee(results: results) {
                operationExtraFees.add(extraFee: allocationFee)
            }
            if let burnFee = parseBurnFee(results: results) {
                operationExtraFees.add(extraFee: burnFee)
            }
            
            var consumedGas = Int(results.consumed_gas ?? "0") ?? 0
            var consumedStorage = Int(results.paid_storage_size_diff ?? "0") ?? 0
            
            if let internalResults = metadata.internal_operation_results {
                internalResults.forEach { internalResult in
                    if let parsedResult = parseInternalOperationResult(internalResult: internalResult) {
                        consumedGas += parsedResult.consumedGas
                        consumedStorage += parsedResult.consumedStorage
                        operationExtraFees += parsedResult.extraFees
                    }
                }
            }
            simulations.append(SimulatedFees(type: type, extraFees: operationExtraFees, consumedGas: consumedGas, consumedStorage: consumedStorage))
        }
        return SimulationResponse(simulations: simulations)
    }

    private func parseAllocationFee(results: TezosSimulationMetadataOperation) -> ExtraFee? {
        if let updates = results.balance_updates,updates.count > 2 {
            let update = updates[2]
            if let value = update.change {
                let fee = value.replacingOccurrences(of: "-", with: "")
                return AllocationFee(feeString:fee)
            }
        }
        return nil
    }
    
    private func parseBurnFee(results: TezosSimulationMetadataOperation) -> ExtraFee? {
        if let sizeDiffString = results.paid_storage_size_diff,let sizeDiff = Double(sizeDiffString) {
            if sizeDiff > 0 {
                let burn = sizeDiff * (Double(constants.cost_per_byte!) ?? 0)
                return BurnFee(feeString: String(burn))
            }
        }
        return nil
    }
    
    private func parseInternalOperationResult(internalResult:TezosSimulationMetadataInternal) -> InternalOperationResult? {
        if let result = internalResult.result,
           let internalConsumedGasStr = result.consumed_gas,
           let internalConsumedStorageStr = result.paid_storage_size_diff {
            let internalConsumedGas = Int(internalConsumedGasStr) ?? 0
            let internalConsumedStorage = Int(internalConsumedStorageStr) ?? 0
            var extraFees = ExtraFees()
            if let allocationFee = parseAllocationFee(results: result) {
                extraFees.add(extraFee: allocationFee)
            }
            
            if let burnFee = parseBurnFee(results: result) {
                extraFees.add(extraFee: burnFee)
            }
            
            if let moreResult = internalResult.result,let statusString = moreResult.status {
                let status = OperationResultStatus.get(status: statusString)
                return InternalOperationResult(consumedGas: internalConsumedGas,consumedStorage: internalConsumedStorage,extraFees: extraFees,status: status
                )
            }
        }
        return nil
    }
    
    
//    public func parseSimulation(jsonDic:[String:Any]) -> SimulationResponse? {
//        var simulations = [SimulatedFees]()
//        if let contents = jsonDic["contents"] as? Array<[String:Any]> {
//            for content in contents {
//                if let type = content["kind"] as? String,let metadata = content["metadata"] as? [String:Any],let results = metadata["operation_result"] as? [String:Any],let status = results["status"] as? String {
//                    if OperationResultStatus.get(status: status) == .FAILED {return nil}
//                    var operationExtraFees = ExtraFees()
//                    if let allocationFee = parseAllocationFee(results: results) {
//                        operationExtraFees.add(extraFee: allocationFee)
//                    }
//                    if let burnFee = parseBurnFee(results: results) {
//                        operationExtraFees.add(extraFee: burnFee)
//                    }
//
//                    var consumedGas = Int((results["consumed_gas"] as? String) ?? "0")  ?? 0
//                    var consumedStorage = Int((results["paid_storage_size_diff"] as? String) ?? "0") ?? 0
//                    if let internalResults = metadata["internal_operation_results"] as? Array<[String:Any]> {
//                        internalResults.forEach({ internalResult in
//                            if let parsedResult = parseInternalOperationResult(internalResult: internalResult) {
//                                consumedGas += parsedResult.consumedGas
//                                consumedStorage += parsedResult.consumedStorage
//                                operationExtraFees += parsedResult.extraFees
//                            }
//                        })
//                    }
//                    simulations.append(SimulatedFees(type: type, extraFees: operationExtraFees, consumedGas: consumedGas, consumedStorage: consumedStorage))
//                } else {
//                    return nil
//                }
//            }
//        }
//        return SimulationResponse(simulations: simulations)
//    }
//
//    private func parseAllocationFee(results: [String:Any]) -> ExtraFee? {
//        if let _ = results["allocated_destination_contract"] as? [String:Any],let updates = results["balance_updates"] as? Array<Any> {
//            if updates.count > 2 {
//                if let update = updates[2] as? Dictionary<String,String>, let value = update["change"] {
//                    let fee = value.replacingOccurrences(of: "-", with: "")
//                    return AllocationFee(feeString:fee)
//                }
//            }
//        }
//        return nil
//    }
//
//    private func parseBurnFee(results: [String:Any]) -> ExtraFee? {
//        if let sizeDiffString = results["paid_storage_size_diff"] as? String,let sizeDiff = Double(sizeDiffString) {
//            if sizeDiff > 0 {
//                let burn = sizeDiff * (Double(constants.cost_per_byte!) ?? 0)
//                return BurnFee(feeString: String(burn))
//            }
//        }
//        return nil
//    }
//
//    private func parseInternalOperationResult(internalResult:[String:Any]) -> InternalOperationResult? {
//        if let result  = internalResult["result"] as? [String:Any] {
//            let internalConsumedGasStr = result["consumed_gas"] as? String
//            let internalConsumedStorageStr = result["paid_storage_size_diff"] as? String
//            let internalConsumedGas = Int(internalConsumedGasStr ?? "0") ?? 0
//            let internalConsumedStorage = Int(internalConsumedStorageStr ?? "0") ?? 0
//            var extraFees = ExtraFees()
//            if let allocationFee = parseAllocationFee(results: result) {
//                extraFees.add(extraFee: allocationFee)
//            }
//
//            if let burnFee = parseBurnFee(results: result) {
//                extraFees.add(extraFee: burnFee)
//            }
//
//            let moreResult = internalResult["result"] as! [String:Any]
//            let statusString = moreResult["status"] as! String
//            let status = OperationResultStatus.get(status: statusString)
//            return InternalOperationResult(consumedGas: internalConsumedGas,consumedStorage: internalConsumedStorage,extraFees: extraFees,status: status
//            )
//        }
//        return nil
//    }
}

private struct InternalOperationResult{
    let consumedGas: Int
    let consumedStorage: Int
    let extraFees: ExtraFees
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
