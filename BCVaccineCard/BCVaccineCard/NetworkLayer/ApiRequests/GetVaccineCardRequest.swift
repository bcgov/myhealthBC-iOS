//
//  GetVaccineCardRequest.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
// https://test.healthgateway.gov.bc.ca/api/immunizationservice/v1/api/VaccineStatus

import Foundation

class GetVaccineCardRequest: ApiRequest<GatewayVaccineCard> {
    
    var model: GatewayPersonalDetailsModel!
    
    override func endPoint() -> String {
        return "api/VaccineStatus/"
    }
    
    override func headerParams() -> NSDictionary? {
        return [
            "phn": model.phn,
            "dateOfBirth": model.dateOfBirth,
            "dateOfVaccine": model.dateOfVaccine
        ]
    }
    
    override func requestType() -> HTTPMethod {
        return .get
    }
}
