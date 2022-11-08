//
//  Network.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation
import Alamofire

extension NetworkRequest.RequestType {
    var AFMethod: HTTPMethod {
        switch self {
        case .Get:
            return .get
        case .Post:
            return .post
        case .Put:
            return .put
        case .Delete:
            return .delete
        }
    }
}

extension NetworkRequest {
    var AFRequest:  DataRequest {
        let afHeaders: HTTPHeaders?
        if let requestHeaders = headers {
            afHeaders = HTTPHeaders(requestHeaders)
        } else {
            afHeaders = nil
        }
        let alamoEncoder: ParameterEncoder = encoder == .json ? .json : .urlEncodedForm
        return AF.request(url, method: type.AFMethod, parameters: parameters, encoder: alamoEncoder, headers: afHeaders)
    }
}


struct AFNetwork: Network {
    
    func request<Parameters: Encodable, T: Decodable>(with requestData: NetworkRequest<Parameters, T>) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Decode UNIX timestamps
        let AFRequest = requestData.AFRequest
        AFRequest.responseDecodable(of: T.self, decoder: decoder, completionHandler: {response in
            if let res = response.value {
                return requestData.completion(res)
            } else {
                Logger.log(string: response.error.debugDescription, type: .Network)
                return requestData.completion(nil)
            }
            
        })
        
    }
}
