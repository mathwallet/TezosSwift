//
//  TezosPreapplyResponseParser.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/23.
//

import Foundation

public struct TezosPreapplyResponseParser {    
    public static func parse(results:Array<PreappleOperationResult>) -> Bool {
        for result in results {
            guard let contents = result.contents else {
                return false
            }
            for content in contents {
                guard let metadata = content.metadata,let results = metadata.operation_result,let status = results.status else {
                    return false
                }
                if OperationResultStatus.get(status: status) == .FAILED {
                    return false
                }
            }
        }
        return true
    }
}
