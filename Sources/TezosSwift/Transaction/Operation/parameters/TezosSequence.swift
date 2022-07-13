//
//  MichelineSequence.swift
//  
//
//  Created by Mike Godenzi on 23.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

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
