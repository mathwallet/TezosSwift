

import Foundation


public struct TezosPrim: Codable, Hashable, Equatable {
    public let prim: String
    public let args: [TezosArg]?
    public let annots: [String]?
    
    public init(prim: String, args: [TezosArg]? = nil, annots: [String]? = nil) {
        self.prim = prim
        self.args = args
        self.annots = annots
    }
}

