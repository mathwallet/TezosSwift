//
//  Data+Extension.swift
//  
//
//  Created by mathwallet on 2022/7/15.
//

import Foundation
import Blake2
import CryptoSwift

extension Data {
    func genericHash(outputLength: Int) throws -> Data {
        return try Blake2.hash(.b2b, size: outputLength, bytes: self.bytes)
    }
}
