//
//  TezosPreapplyResponseParser.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/23.
//

import Foundation

public struct TezosPreapplyResponseParser {
    
    public static func parse(results:PreappleOperationResult) -> Bool {
        if let contents = results.contents {
            for content in contents{
                guard let metadata = content.metadata,let results = metadata.operation_result,let status = results.status else {
                    return false
                }
                if OperationResultStatus.get(status: status) == .failed {
                    return false
                }
            }
            return true
        }else {
            return false
        }
    }
}
