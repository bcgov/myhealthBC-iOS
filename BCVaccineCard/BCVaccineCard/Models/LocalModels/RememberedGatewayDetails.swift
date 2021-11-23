//
//  RememberedGatewayDetails.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-01.
//

import Foundation

struct RememberedGatewayDetails: Codable {
    var storageArray: [GatewayStorageProperties]?
    
    func getIndexOfPHN(_ phn: String) -> Int? {
        guard let storageArray = storageArray else { return nil }
        return storageArray.firstIndex { $0.phn == phn }
    }
}

struct GatewayStorageProperties: Codable {
    var phn: String
    var dob: String
}
