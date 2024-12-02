//
//  TezosFeeEstimatorService.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/22.
//

import Foundation

public struct TezosFeeEstimatorService {
    private let MILLIGAS_BUFFER = 100 * 1000
    private let STORAGE_BUFFER = 20
    public func getForgedOperationsSize(forgeResult: String) -> Int {
        return forgeResult.count/2 + 64
    }
    
    public func calculateFeesAndCreateOperation(response:SimulationResponse,operation:TransactionOperation,operationSize: Int) -> TransactionOperation{
        let fees = self.calculateFees(response: response, operationSize: operationSize)
        return self.createOperation(operation: operation, fees: fees)
    }
    
    public func calculateFees(response:SimulationResponse,operationSize: Int) -> OperationFees {
        var listOfFees = [OperationFees]()
        var accumulatedFee = OperationFees(fee: 0, gasLimit: 0, storageLimit: 0,extrafees: ExtraFees())
        response.simulations.forEach { simulatedFee in
            let operationFee = calculateOperationFees(simulation: simulatedFee, operationSize: operationSize)
            accumulatedFee = operationFee + accumulatedFee
            listOfFees.append(operationFee)
        }
        
        return CalculatedFees(operationFees: listOfFees, accumulatedFee: accumulatedFee).accumulatedFee
    }
    
    private func calculateOperationFees(
        simulation: SimulatedFees,
        operationSize: Int
    ) -> OperationFees {
        let initialFee = calculateBakerFee(operationSize:operationSize, gas:simulation.consumedGas)
        
        let gasLimit = simulation.consumedGas + 400
        let storageLimit = simulation.consumedStorage + 257
        let extraFees = simulation.extraFees
        
        return OperationFees(fee: initialFee, gasLimit: gasLimit, storageLimit: storageLimit, extrafees: extraFees)
    }
    
    func calculateBakerFee(operationSize: Int,gas: Int) -> Int {
        let storageFee = operationSize * 1000
        let gasFee = gas * 100
        return 200 + nanoIntToInt(storageFee) + nanoIntToInt(gasFee)
    }
    
   func nanoIntToInt(_ nanoInt: Int) -> Int {
        if nanoInt % 1000 == 0{
           return nanoInt/1000
        }
        return (nanoInt/1000)+1
    }
}

extension TezosFeeEstimatorService  {
    public func createOperation(operation:TransactionOperation,fees: OperationFees) -> TransactionOperation {
        return TransactionOperation(source: operation.source, destination: operation.destination, amount: operation.amount,counter: operation.counter, kind: operation.kind, operationFees: fees, parameters: operation.parameters)
    }
}
