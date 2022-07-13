

import Foundation


public typealias TezosSequence = [TezosArg]

public indirect enum TezosArg: Codable, Equatable, Hashable {
    case prim(TezosPrim)
    case literal(TezosLiteral)
    case sequence(TezosSequence)
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if container.contains(.prim) {
                self = .prim(try Prim(from: decoder))
            } else {
                self = .literal(try Literal(from: decoder))
            }
        } else {
            var container = try decoder.unkeyedContainer()
            self = .sequence(try Sequence(from: &container))
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

