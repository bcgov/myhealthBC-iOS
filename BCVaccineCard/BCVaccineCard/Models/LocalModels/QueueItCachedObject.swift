//
//  QueueItCachedObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-15.
//

import Foundation

struct QueueItCachedObject: Codable {
    var customerID: String?
    var eventAlias: String?
    var queueitToken: String?
    var cookieHeader: [String: String]?
//    var existingRequest: GatewayVaccineCardRequest?
}
