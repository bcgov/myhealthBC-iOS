//
//  LabOrderService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-31.
//

import Foundation

typealias labOrdersResponse = AuthenticatedLaboratoryOrdersResponseObject

struct LabOrderService {
    
    let network: Network
    let authManager: AuthManager
    private let maxRetry = Constants.NetworkRetryAttempts.publicRetryMaxForTestResults
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    // MARK: Store
    private func store(labOrders response: labOrdersResponse,
                        for dependent: Dependent,
                        completion: @escaping ([LaboratoryOrder])->Void
    ) {
        guard let patient = dependent.info else { return completion([]) }
        
        let stored = StorageService.shared.storeLaboratoryOrders(patient: patient, gateWayResponse: response)
        // TODO: Connor Test stored
        return completion(stored)
    }
    
}

// MARK: Network requests
extension LabOrderService {
    
}
