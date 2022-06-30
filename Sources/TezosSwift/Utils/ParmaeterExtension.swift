//
//  ParmaeterExtension.swift
//  MathWallet5
//
//  Created by xgblin on 2022/6/23.
//

import Foundation
import Alamofire

private let arrayParametersKey = "arrayParametersKey"

extension Array {
    public func asParameters() -> Parameters {
        return [arrayParametersKey:self] as! Parameters
    }
}

public struct ArrayEncoding: ParameterEncoding {

    public static var `default`: ArrayEncoding { ArrayEncoding() }
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = data

        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
    }
}


private let stringParametersKey = "stringParametersKey"

extension String {
    public func asParameters() -> Parameters {
        return [stringParametersKey:self]
    }
}

public struct StringEncoding: ParameterEncoding {
    
    public static var `default`: StringEncoding { StringEncoding() }
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters,
            let string = parameters[stringParametersKey] as? String else {
                return urlRequest
        }
        
        do {
            let data = try JSONEncoder().encode(string)

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = data

        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        return urlRequest
    }
}
