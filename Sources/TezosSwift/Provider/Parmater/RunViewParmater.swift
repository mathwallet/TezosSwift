//
//  RunViewParmater.swift
//  
//
//  Created by xgblin on 2022/7/14.
//

import Foundation

public struct RunViewParmater: Encodable {
    public let unparsing_mode:String
    public let contract:String
    public let entrypoint:String
    public let chain_id:String
    public let input:TezosArg
}
