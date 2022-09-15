//
//  CommunicationService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation


extension CommunicationBanner {
    var shouldDisplay: Bool {
        guard !CommunicationSetvice(network: AFNetwork()).isDismissed(message: self) else {return false}
        guard let effectiveDateTime = effectiveDateTime.getGatewayDate(), let expiryDateTime = expiryDateTime.getGatewayDate() else {return false}
        return effectiveDateTime < Date() && expiryDateTime > Date()
    }
}

struct CommunicationSetvice {
    fileprivate static var dismissed: [CommunicationBanner] = []
    
    let network: Network
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func fetchMessage(completion: @escaping(_ message: CommunicationBanner?) -> Void) {
        let requestModel = NetworkRequest<DefaultParams, CommunicationResponse>(url: endpoints.communicationsMobile, type: .Get, parameters: nil, headers: nil) { result in
            completion(result?.resourcePayload)
        }
        
        network.request(with: requestModel)
    }
    
    func isDismissed(message: CommunicationBanner) -> Bool {
        guard let hash = message.md5Hash() else {return false}
        return CommunicationSetvice.dismissed.contains(where: {$0.md5Hash() == hash})
    }
    
    func dismiss(message: CommunicationBanner) {
        
        if isDismissed(message: message) {
            return
        } else {
            CommunicationSetvice.dismissed.append(message)
        }
    }
}

