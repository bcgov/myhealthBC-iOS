//
//  CommunicationService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation

struct CommunicationSetvice {
    let network: Network
    
    var endpoints: UrlAccessor {
        return UrlAccessor() // No Need for DI on endpoints - they're constants.
    }
    
    func fetchMessage(completion: @escaping(_ message: CommunicationMessage?) -> Void) {
        let requestModel = NetworkRequest<DefaultParams, CommunicationResponse>(url: endpoints.communicationsMobile, type: .Get, parameters: nil, headers: nil) { result in
            print(result)
            completion(result?.resourcePayload)
        }
        
        network.request(with: requestModel)
    }
}

