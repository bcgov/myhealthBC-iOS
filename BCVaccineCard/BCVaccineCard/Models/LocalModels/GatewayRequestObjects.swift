//
//  GatewayPersonalDetailsModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import Foundation

// MARK: GatewayVaccineCardRequest

struct GatewayVaccineCardRequest: Codable {
    let phn: String
    let dateOfBirth: String /// yyyy-MM-dd
    let dateOfVaccine: String /// yyyy-MM-dd
}

struct GatewayTestResultRequest: Codable {
    let phn: String
    let dateOfBirth: String /// yyyy-MM-dd
    let collectionDate: String /// yyyy-MM-dd
}
