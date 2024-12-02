import Foundation

public let defultoperationFees = OperationFees(fee: 0, gasLimit: MAXGAS, storageLimit: MAXSTORAGE)
public class TransactionOperation:TezosOperation {
    var kind:TezosOperationKind
    var source: String
    var destination: String
    var counter: String
    var amount: String = "0"
    public var operationFees:OperationFees
    public var parameters:TezosParameters?
    
    public init(source: String,destination: String,amount: String,counter: String,kind:TezosOperationKind = .transaction,operationFees:OperationFees? = nil,parameters:TezosParameters? = nil) {
        self.source = source
        self.destination = destination
        self.counter = counter
        self.amount = amount
        self.kind = kind
        self.operationFees = operationFees ?? defultoperationFees
        self.parameters = parameters
    }
    
    private enum OperationKeys: String, CodingKey {
        case kind = "kind"
        case counter = "counter"
        case storageLimit = "storage_limit"
        case gasLimit = "gas_limit"
        case fee = "fee"
        case destination = "destination"
        case amount = "amount"
        case source = "source"
        case parameters = "parameters"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OperationKeys.self)
        try container.encode(kind.rawValue, forKey: .kind)
        try container.encode(String(counter), forKey: .counter)
        let operationFees = self.operationFees
        try container.encode(String(operationFees.storageLimit), forKey: .storageLimit)
        try container.encode(String(operationFees.gasLimit), forKey: .gasLimit)
        try container.encode(String(operationFees.fee), forKey: .fee)
        try container.encode(amount, forKey: .amount)
        try container.encode(source, forKey: .source)
        try container.encode(destination, forKey: .destination)
        try container.encodeIfPresent(parameters, forKey: .parameters)
    }


}
// createParameters
extension TransactionOperation {
    
    public func configFa1_2Prameter(source: String,toTokenAddress: String,tokenAmount: String) {
        let amountArgs: [TezosArg] = [TezosArg.literal(TezosLiteral.string(toTokenAddress)),TezosArg.literal(TezosLiteral.int(tokenAmount))]
        let amountPrim = TezosPrim(prim: "Pair",args: amountArgs)
        
        let fromArgs: [TezosArg] = [TezosArg.literal(TezosLiteral.string(source)),TezosArg.prim(amountPrim)]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        self.parameters = TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.prim(valuePrim))
    }
    
    public func configFa2Prameter(source: String,toTokenAddress: String,tokenAmount: String,tokenId: String) {
        let amountArgs: [TezosArg] = [TezosArg.literal(TezosLiteral.int(tokenId)),TezosArg.literal(TezosLiteral.int(tokenAmount))]
        let amountPrim = TezosPrim(prim: "Pair", args: amountArgs)
        
        let toArgs: [TezosArg] = [TezosArg.literal(TezosLiteral.string(toTokenAddress)),TezosArg.prim(amountPrim)]
        let toPrim = TezosPrim(prim: "Pair", args:toArgs)
        
        let fromArgs = [TezosArg.literal(TezosLiteral.string(source)),TezosArg.sequence([TezosArg.prim(toPrim)])]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        self.parameters = TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.sequence([TezosArg.prim(valuePrim)]))
    }
}

public enum TezosOperationKind: String {
    // Implemented operations
    case transaction = "transaction"
    case reveal = "reveal"
    case delegation = "delegation"

    // Planned / Unimplemented
    case origination = "origination"
    case activateAccount = "activate_account"
}
