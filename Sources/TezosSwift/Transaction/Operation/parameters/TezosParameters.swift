//
//  File.swift
//  
//
//  Created by 薛跃杰 on 2022/7/13.
//

import Foundation

public struct TezosParameters: Codable, Equatable {
    
    public let entrypoint: Entrypoint
    public let value: TezosPrim
    
    public init(entrypoint: Entrypoint, value: TezosArg) {
        self.entrypoint = entrypoint
        self.value = value
    }
    
    public enum Entrypoint: Equatable, Codable {
        case common(Common)
        case custom(String)
        
        public init(from decoder: Decoder) throws {
            if let common = try? Common(from: decoder) {
                self = .common(common)
                return
            }
            let container = try decoder.singleValueContainer()
            let custom = try container.decode(String.self)
            self = .custom(custom)
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .common(value):
                try value.encode(to: encoder)
            case let .custom(value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            }
        }
        
        public enum Common: String, Codable {
            case `default`
            case root
            case `do`
            case setDelegate = "set_delegate"
            case removeDelegate = "remove_delegate"
        }
    }
}
