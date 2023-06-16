//
//  PostNoteResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation

struct PostNoteResponse: Codable {
    let resourcePayload: NoteResponse?
    let totalResultCount, pageIndex, pageSize: Int?
    let resultError: ResultError?
}

// MARK: - Note Response Payload
struct NoteResponse: Codable {
    let id, hdID, title, text: String?
    let journalDate: String?
    let version: Int?
    let createdDateTime, createdBy, updatedDateTime, updatedBy: String?

    enum CodingKeys: String, CodingKey {
        case id
        case hdID = "hdId"
        case title, text, journalDate, version, createdDateTime, createdBy, updatedDateTime, updatedBy
    }
}
