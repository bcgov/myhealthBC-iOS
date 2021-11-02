//
//  RememberedGatewayDetails.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-01.
//

import Foundation

struct RememberedGatewayDetails: Codable {
    var storageArray: [GatewayStorageProperties]?
}

struct GatewayStorageProperties: Codable {
    var phn: String
    var dob: String
}
