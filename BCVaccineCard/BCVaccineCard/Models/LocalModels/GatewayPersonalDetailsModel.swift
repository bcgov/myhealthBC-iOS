//
//  GatewayPersonalDetailsModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import Foundation

struct GatewayPersonalDetailsModel: Codable {
    let phn: String
    let dateOfBirth: String /// yyyy-MM-dd
    let dateOfVaccine: String /// yyyy-MM-dd
    
    // TODO: Come up with a protocol or extension to fetch the key (without using coding keys)... though that may be the only way to go about it
//    var getKey: String {
//
//    }
}
