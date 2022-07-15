import Foundation

public let defultoperationFees = OperationFees(fee: 0, gasLimit: MAXGAS, storageLimit: MAXSTORAGE)
public class TransactionOperation:Encodable {
    var kind:TezosOperationKind
    var source:String
    var destination:String
    var counter:String
    var amount:String = "0"
    public var operationFees:OperationFees
    public var parameters:TezosParameters?
    public init(from:String,to:String,counter:String,amount:String,kind:TezosOperationKind = .transaction,operationFees:OperationFees? = nil,parameters:TezosParameters? = nil) {
        self.source = from
        self.destination = to
        self.counter = counter
        self.amount = amount
        self.kind = kind
        self.operationFees = operationFees ?? defultoperationFees
        self.parameters = parameters
    }
    
    public init(source:String,counter:String,destination:String,amount:String,kind:TezosOperationKind = .transaction,operationFees:OperationFees? = nil,parameters:TezosParameters? = nil) {
        self.source = source
        self.destination = destination
        self.counter = counter
        self.amount = amount
        self.kind = kind
        self.operationFees = operationFees ?? defultoperationFees
        self.parameters = parameters
    }
    
    //Fa1.2
    
    public init(from: String, to: String,mint:String, counter: String, amount: String, kind: TezosOperationKind = .transaction, operationFees: OperationFees? = nil) {
        self.source = from
        self.destination = mint
        self.counter = counter
        self.amount = "0"
        self.kind = kind
        self.operationFees = operationFees ?? defultoperationFees
        self.parameters = self.createFa1_2Parameters(from:from, to: to, amount: amount)
    }
    
    //Fa2
    public init(from: String, to: String,mint:String, counter: String, amount: String,tokenId:String = "0",kind: TezosOperationKind = .transaction, operationFees: OperationFees? = nil)  {
        self.source = from
        self.destination = mint
        self.counter = counter
        self.kind = kind
        self.amount = "0"
        self.operationFees = operationFees ?? defultoperationFees
        self.parameters = self.createFa2Parameters(from:from, to: to, amount: amount,tokenId: tokenId)
    }
    

}
// createParameters
extension TransactionOperation {
    private func createFa1_2Parameters(from:String,to:String,amount:String) -> TezosParameters {
        let amountArgs:[TezosArg] = [TezosArg.literal(TezosLiteral.string(to)),TezosArg.literal(TezosLiteral.int(amount))]
        let amountPrim = TezosPrim(prim: "Pair",args: amountArgs)
        
        let fromArgs:[TezosArg] = [TezosArg.literal(TezosLiteral.string(from)),TezosArg.prim(amountPrim)]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        
        return TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.prim(valuePrim))
    }
    
    private func createFa2Parameters(from:String,to:String,amount:String,tokenId:String) -> TezosParameters {
        let amountArgs:[TezosArg] = [TezosArg.literal(TezosLiteral.int(tokenId)),TezosArg.literal(TezosLiteral.int(amount))]
        let amountPrim = TezosPrim(prim: "Pair", args: amountArgs)
        
        let toArgs:[TezosArg] = [TezosArg.literal(TezosLiteral.string(to)),TezosArg.prim(amountPrim)]
        let toPrim = TezosPrim(prim: "Pair", args:toArgs)
        
        let fromArgs = [TezosArg.literal(TezosLiteral.string(from)),TezosArg.sequence([TezosArg.prim(toPrim)])]
        let valuePrim = TezosPrim(prim: "Pair", args:fromArgs)
        
        return TezosParameters(entrypoint: TezosParameters.Entrypoint.custom("transfer"), value: TezosArg.sequence([TezosArg.prim(valuePrim)]))
    }
}

//encode
extension TransactionOperation {
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OperationKeys.self)
        try container.encode(kind.rawValue, forKey: .kind)
        try container.encode(String(counter), forKey: .counter)
        let operationFees = self.operationFees
        try container.encode(String(operationFees.storageLimit), forKey: .storageLimit)
        try container.encode(String(operationFees.gasLimit), forKey: .gasLimit)
        try container.encode(String(operationFees.fee), forKey: .fee)
        try container.encode(amount, forKey: .amount)
        try container.encode(source, forKey: .source)
        try container.encode(destination, forKey: .source)
        try container.encode(parameters, forKey: .parameters)
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
