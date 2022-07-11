//
//  TezosFeeEstimatorService.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/22.
//

import Foundation
import BeaconBlockchainTezos

public struct TezosFeeEstimatorService {
    public func getForgedOperationsSize(forgeResult:String) -> Int {
        return forgeResult.count/2 + 64
    }
    
    public func calculateFeesAndCreatOperation(response:SimulationResponse,operation:Tezos.Operation,operationSize:Int) -> Tezos.Operation{
        let fees = self.calculateFees(response: response, operationSize: operationSize)
        return self.createOperation(operation: operation, fees: fees)
    }
    
    public func calculateFees(response:SimulationResponse,operationSize:Int) -> FeesOperation {
        var listOfFees = [FeesOperation]()
        var accumulatedFee = FeesOperation(fee: 0, gasLimit: 0, storageLimit: 0,extrafees: ExtraFees())
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
    ) -> FeesOperation {
        let initialFee = calculateBakerFee(operationSize:operationSize, gas:simulation.consumedGas)
        
        let gasLimit = simulation.consumedGas + 400
        let storageLimit = simulation.consumedStorage + 257
        let extraFees = simulation.extraFees
        
        return FeesOperation(fee: initialFee, gasLimit: gasLimit, storageLimit: storageLimit, extrafees: extraFees)
    }
    
    func calculateBakerFee(operationSize: Int,gas: Int) -> Int {
        let storageFee = operationSize * 1000
        let gasFee = gas * 100
        return 200 + nanoIntToInt(storageFee) + nanoIntToInt(gasFee)
    }
    
   func nanoIntToInt(_ nanoInt:Int) -> Int {
        if nanoInt % 1000 == 0{
           return nanoInt/1000
        }
        return (nanoInt/1000)+1
    }
}

extension TezosFeeEstimatorService  {
    public func createOperation(operation:Tezos.Operation,fees: FeesOperation) -> Tezos.Operation {
        switch operation {
        case let .transaction(content):
            return Tezos.Operation.transaction(Tezos.Operation.Transaction(source:content.source , fee:"\(fees.fee)" , counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", amount: content.amount, destination: content.destination, parameters: content.parameters))
        case let .reveal(content):
            return Tezos.Operation.reveal(Tezos.Operation.Reveal(source: content.source, fee: "\(fees.fee)", counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", publicKey: content.publicKey))
        case let .origination(content):
            return Tezos.Operation.origination(Tezos.Operation.Origination(source: content.source, fee: "\(fees.fee)", counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", balance: content.balance, delegate: content.delegate, script: content.script))
        case let .delegation(content):
            return Tezos.Operation.delegation(Tezos.Operation.Delegation(source: content.source, fee: "\(fees.fee)", counter: content.counter, gasLimit: "\(fees.gasLimit)", storageLimit: "\(fees.storageLimit)", delegate: content.delegate))
        default :
            return operation
        }
    }
}
