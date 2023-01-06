//
//  Network.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation

struct NetworkRequest<Parameters: Encodable, T: Decodable> {
    
    typealias Completion<T: Decodable> = ((_ Result: T?) -> Void)
    
    var maxAttempts: Int = 3 // if can be re-tried, max number of attempts allowed
    var retryIn: Int = 1000 // if can be re-tried, time to wait until next try
    var attempts: Int = 0
    
    let url: URL
    let type: RequestType
    
    let parameters: Parameters?
    var encoder: EncoderType = .json
    let headers: [String: String]?
    let completion: Completion<T>
    
    
    mutating func incremenetAttempts() {
        attempts = attempts + 1
    }
    
    var shouldRetry: Bool {
        return attempts < maxAttempts
    }
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
