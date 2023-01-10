//
//  Network.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation

struct NetworkRequest<Parameters: Encodable, T: Decodable> {
    
    typealias Completion<T: Decodable> = ((_ Result: T?) -> Void)
    typealias Error = ((_ type: ErrorType) -> Void)
    
    // if can be re-tried, max number of attempts allowed
    var maxAttempts: Int = Constants.NetworkRetryAttempts.maxRetry
    // if can be re-tried, time to wait until next try
    var retryIn: Int =  Constants.NetworkRetryAttempts.retryIn
    
    let url: URL
    let type: RequestType
    
    let parameters: Parameters?
    var encoder: EncoderType = .json
    let headers: [String: String]?
    let completion: Completion<T>
    
    var onError: Error? = nil // Optional completion handler for returning errors
}

extension NetworkRequest {
    enum RequestType {
        case Get
        case Post
        case Put
        case Delete
    }
}

extension NetworkRequest {
    enum ErrorType {
        case FailedAfterRetry
//        case NoData
//        case UnexpectedResponse
    }
}

extension NetworkRequest {
    enum EncoderType {
        case json
        case urlEncoder
    }
}

struct DefaultParams: Codable {
    
}

struct HDIDParams: Codable {
    let hdid: String
}
