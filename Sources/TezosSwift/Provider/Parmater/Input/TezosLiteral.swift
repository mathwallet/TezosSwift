

import Foundation
import CryptoSwift

public enum TezosLiteral: Codable, Hashable, Equatable {
    case string(String)
    case int(String)
    case bytes([UInt8])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .string) {
            self = .string(value)
            return
        }
        if let value = try container.decodeIfPresent(String.self, forKey: .int) {
            self = .int(value)
            return
        }
        if let value = try container.decodeIfPresent(String.self, forKey: .bytes) {
            self = .bytes(Data(hex: value).bytes)
            return
        }
        throw SerializationError.invalidType
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .string(value):
            try container.encode(value, forKey: .string)
        case let .int(value):
            try container.encode(value, forKey: .int)
        case let .bytes(value):
            try container.encode(value.toHexString(), forKey: .bytes)
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case string
        case int
        case bytes
    }
    
    public enum SerializationError: Swift.Error {
        case invalidType
    }
}

