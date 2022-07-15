

import Foundation

public typealias TezosSequence = [TezosArg]

extension TezosSequence {

    public init(from container: inout UnkeyedDecodingContainer) throws {
        guard let count = container.count, count > 0 else {
            self = []
            return
        }
        var result = [TezosArg]()
        result.reserveCapacity(count)
        while !container.isAtEnd {
            result.append(try container.decode(TezosArg.self))
        }
        assert(result.count == count)
        self = result
    }
}

public enum TezosArg: Codable, Equatable, Hashable {
    case prim(TezosPrim)
    case literal(TezosLiteral)
    case sequence(TezosSequence)
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if container.contains(.prim) {
                self = .prim(try TezosPrim(from: decoder))
            } else {
                self = .literal(try TezosLiteral(from: decoder))
            }
        } else {
            var container = try decoder.unkeyedContainer()
            self = .sequence(try TezosSequence(from: &container))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .prim(prim):
            try prim.encode(to: encoder)
        case let .literal(literal):
            try literal.encode(to: encoder)
        case let .sequence(array):
            var container = encoder.unkeyedContainer()
            for mv1e in array {
                try container.encode(mv1e)
            }
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case prim
    }
}

