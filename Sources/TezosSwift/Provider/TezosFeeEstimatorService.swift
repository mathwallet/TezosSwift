//
//  TezosFeeEstimatorService.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/22.
//

import Foundation

public struct TezosFeeEstimatorService {
    public func getForgedOperationsSize(forgeResult:String) -> Int {
        return forgeResult.count + 64
    }
    
    public func calculateFees(response:SimulationResponse,operationSize:Int) -> CalculatedFees {
        var listOfFees = [FeesOperation]()
        var accumulatedFee = FeesOperation(fee: 0, gasLimit: 0, storageLimit: 0,extrafees: [ExtraFee(fee: 0)])
        response.simulations.forEach { simulatedFee in
            let operationFee = calculateOperationFees(simulation: simulatedFee, operationSize: operationSize)
            accumulatedFee = operationFee + accumulatedFee
            listOfFees.append(operationFee)
        }
        
        return CalculatedFees(operationsFees: listOfFees, accumulatedFee: accumulatedFee)
    }
    
    private func calculateOperationFees(
        simulation: SimulatedFees,
        operationSize: Int
    ) -> FeesOperation {
        let initialFee = TezosFeeEstimatorService.calculateBakerFee(operationSize:operationSize, gas:simulation.consumedGas)
        
        let gasLimit = simulation.consumedGas + 400
        let storageLimit = simulation.consumedStorage + 257
        let extraFees = simulation.extraFees
        
        return FeesOperation(fee: initialFee, gasLimit: gasLimit, storageLimit: storageLimit, extrafees: extraFees)
    }
    
    static func calculateBakerFee(operationSize: Int,gas: Int) -> Int {
        let storageFee = operationSize * 1000
        let gasFee = gas * 100
        return 200 + nanoIntToInt(storageFee) + nanoIntToInt(gasFee)
    }
    
    static func nanoIntToInt(_ nanoInt:Int) -> Int {
        if nanoInt % 1000 == 0{
           return nanoInt/1000
        }
        return (nanoInt/1000)+1
    }
}
