//
//  AuthenticatedCancerScreeningResponseModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-01-24.
//

import Foundation
// MARK: - CancerScreening
struct AuthenticatedCancerScreeningResponseModel: Codable {
    let items: [Item]?
    
    // MARK: - Item
    struct Item: Codable {
        let eventType, programName, fileID, eventDateTime: String?
        let resultDateTime, itemType, id, type: String?

        enum CodingKeys: String, CodingKey {
            case eventType, programName
            case fileID = "fileId"
            case eventDateTime, resultDateTime
            case itemType = "type"
            case id
            case type = "$type"
        }
    }
}
