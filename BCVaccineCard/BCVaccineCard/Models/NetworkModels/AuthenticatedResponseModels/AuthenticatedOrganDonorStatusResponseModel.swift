//
//  AuthenticatedOrganDonorStatus.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-04-10.
//

import Foundation
// MARK: - OrganDonorStatus
struct AuthenticatedOrganDonorStatusResponseModel: Codable {
    let items: [Item]?
    
    // MARK: - Item
    struct Item: Codable {
        let status, statusMessage, registrationFileID: String?

        enum CodingKeys: String, CodingKey {
            case status, statusMessage
            case registrationFileID = "registrationFileId"
        }
    }
}


