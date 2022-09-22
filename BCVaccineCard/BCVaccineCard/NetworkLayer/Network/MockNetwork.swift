//
//  MockNetwork.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation

struct MockNetwork: Network {
    
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
