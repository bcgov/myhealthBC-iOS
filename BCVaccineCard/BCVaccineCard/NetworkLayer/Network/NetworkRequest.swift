//
//  Network.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation

struct NetworkRequest<Parameters: Encodable, T: Decodable> {
    
    typealias Completion<T: Decodable> = ((_ Result: T?) -> Void)
    
    let url: URL
    let type: RequestType
    
    let parameters: Parameters?
    let headers: [String: String]?
    let completion: Completion<T>
    
}


extension NetworkRequest {
    enum RequestType {
        case Get
        case Post
        case Put
    }
}

struct DefaultParams: Codable {
    
}
