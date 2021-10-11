//
//  HealthGatewayBCWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
//

import Foundation

protocol HealthGatewayBCGateway {
    func requestVaccineCard(_ model: GatewayVaccineCardRequest,
                            completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>)
}

struct HealthGatewayBCWorker {
    let remoteAccess: HealthGatewayBCAccessor
    // If we need local access, can add local access here
}

extension HealthGatewayBCWorker: HealthGatewayBCGateway {
    func requestVaccineCard(_ model: GatewayVaccineCardRequest, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
        self.remoteAccess.requestVaccineCard(model, completion: completion)
    }
}
