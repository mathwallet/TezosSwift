//
//  TezosPreapplyResponseParser.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/23.
//

import Foundation

public struct TezosPreapplyResponseParser {
    public static func parse(jsonArray:Array<Dictionary<String,Any>>) -> Bool {
        for dic in jsonArray {
            guard let contents = dic["contents"] as? Array<Dictionary<String,Any>> else {
                return false
            }
            for content in contents {
                guard let metadata = content["metadata"] as? Dictionary<String,Any> ,let results = metadata["operation_result"] as? Dictionary<String,Any>,let status = results["status"] as? String else {
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
