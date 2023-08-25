//
//  AuthenticatedDiagnosticImagingResponseModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-05-23.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedDiagnosticImagingResponseModel: Codable {
    let items: [Item]?
    
    // MARK: - Item
    struct Item: Codable {
        let procedureDescription, bodyPart, modality, organization: String?
        let healthAuthority, examStatus, fileID, examDate: String?
        let itemType, id, type: String?
        let isUpdated: Bool?

        enum CodingKeys: String, CodingKey {
            case procedureDescription, bodyPart, modality, organization, healthAuthority, examStatus, isUpdated
            case fileID = "fileId"
            case examDate
            case itemType = "type"
            case id
            case type = "$type"
        }
    }
}

