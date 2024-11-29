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
    
    public func parseSimulation(result:OperationContents) -> SimulationResponse? {
        var simulations = [SimulatedFees]()
        if let contents = result.contents {
            for content in contents {
                if let metadata = content.metadata,
                    let results = metadata.operation_result {
                    let type = content.kind
                    let status = results.status
                    if OperationResultStatus.get(status: status) == .failed {return nil}
                    var operationExtraFees = ExtraFees()
                    if let allocationfee = parseAllocationFee(results: results) {
                        operationExtraFees.add(extraFee: allocationfee)
                    }
                    
                    if let burnFee = parseBurnFee(results: results) {
                        operationExtraFees.add(extraFee: burnFee)
                    }
                    
                    var consumedGas = Int(results.consumed_gas ?? "0")  ?? 0
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
                } else {
                    return nil
                }
            }
        }
        return SimulationResponse(simulations: simulations)
    }
    
    
    private func parseAllocationFee(results: OperationResult) -> ExtraFee? {
        if let _ = results.allocated_destination_contract,let updates = results.balance_updates {
            if updates.count > 2 {
                let update = updates[2]
                if let fee = update.change {
                    let feeString = fee.replacingOccurrences(of: "-", with: "")
                    return AllocationFee(feeString: feeString)
                }
            }
        }
        return nil
    }
    
    
    
    private func parseBurnFee(results: OperationResult) -> ExtraFee? {
        if let sizeDiffString = results.paid_storage_size_diff,let sizeDiff = Double(sizeDiffString) {
            if sizeDiff > 0 {
                let burn = sizeDiff * (Double(constants.cost_per_byte!) ?? 0)
                return BurnFee(feeString: String(burn))
            }
        }
        return nil
    }
    
    private func parseInternalOperationResult(internalResult:InternalOperationResult) -> ParseInternalOperationResult? {
        
        if let result = internalResult.result {
            let internalConsumedGasStr = result.consumed_gas ?? "0"
            let internalConsumedStorageStr = result.paid_storage_size_diff ?? "0"
            let internalConsumedGas = Int(internalConsumedGasStr) ?? 0
            let internalConsumedStorage = Int(internalConsumedStorageStr) ?? 0
            var extraFees = ExtraFees()
            if let allocationFee = parseAllocationFee(results: result) {
                extraFees.add(extraFee: allocationFee)
            }
            
            if let burnFee = parseBurnFee(results: result) {
                extraFees.add(extraFee: burnFee)
            }
            
            let moreResult = internalResult.result
            let statusString = moreResult?.status ?? "failed"
            let status = OperationResultStatus.get(status: statusString)
            return ParseInternalOperationResult(consumedGas: internalConsumedGas,consumedStorage: internalConsumedStorage,extraFees: extraFees,status: status)
        }
        return nil
    }
}

private struct ParseInternalOperationResult{
    let consumedGas: Int
    let consumedStorage: Int
    let extraFees: ExtraFees
    let status: OperationResultStatus
}
