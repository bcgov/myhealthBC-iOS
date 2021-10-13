//
//  RemoteRequestAccessor.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
// https://test.healthgateway.gov.bc.ca/api/immunizationservice/v1/api/VaccineStatus

import Foundation

protocol HealthGatewayBCAccessor {
    func requestVaccineCard(_ model: GatewayVaccineCardRequest,
                            completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>)
}

struct RemoteRequestAccessor {
    let accessor: RemoteAccessor
    let endpointsAccessor: EndpointsAccessor
}

extension RemoteRequestAccessor: HealthGatewayBCAccessor {
    
    func requestVaccineCard(_ model: GatewayVaccineCardRequest, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
        let url = self.endpointsAccessor.getVaccineCard
        let interceptor = NetworkRequestInterceptor()
        let headerParameters: Headers = [
            "phn": model.phn,
            "dateOfBirth": model.dateOfBirth,
            "dateOfVaccine": model.dateOfVaccine
        ]
        self.accessor.request(withURL: url, method: .get, headers: headerParameters, interceptor: interceptor, andCompletion: completion)
    }    
}
