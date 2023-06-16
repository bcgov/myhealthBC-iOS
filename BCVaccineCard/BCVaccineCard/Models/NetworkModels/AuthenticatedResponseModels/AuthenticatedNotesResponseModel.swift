//
//  AuthenticatedNotesResponseModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation

// MARK: - AuthenticatedNotesResponseModel
struct AuthenticatedNotesResponseModel: BaseGatewayResponse, Codable {
    var resourcePayload: [NoteResponse]
    var totalResultCount, pageIndex, pageSize: Int?
    var resultError: ResultError?
}

