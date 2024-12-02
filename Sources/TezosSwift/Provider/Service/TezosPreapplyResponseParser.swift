//
//  TezosPreapplyResponseParser.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/23.
//

import Foundation

public struct TezosPreapplyResponseParser {
    
    public static func parse(results: [OperationContents]) -> Bool {
        for result in results {
            if let contents = result.contents {
                for content in contents {
                    guard let metadata = content.metadata else {
                        return false
                    }
                    if let results = metadata.operation_result {
                        let status = results.status
                        if OperationResultStatus.get(status: status) == .failed {
                            return false
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}
