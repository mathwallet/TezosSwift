//
//  TezosPreapplyResponseParser.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/23.
//

import Foundation

public struct TezosPreapplyResponseParser {
    
    public static func parse(results:[OperationContents]) -> Bool {
       for result in results {
           for content in result.contents {
               guard let metadata = content.metadata else {
                   return false
               }
               let results = metadata.operation_result
               let status = results.status
               if OperationResultStatus.get(status: status) == .failed {
                   return false
               }
           }
           return true
        }
        return false
    }
}
