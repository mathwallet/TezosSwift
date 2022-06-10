//
//  File.swift
//  
//
//  Created by 薛跃杰 on 2022/6/10.
//

import Foundation

public struct TezosTokenBalanceResult:Codable {
    public var kind:String?
    public var id:Double?
    public var contract:Int?
    public var expected:String?
    public var found:String?
}
