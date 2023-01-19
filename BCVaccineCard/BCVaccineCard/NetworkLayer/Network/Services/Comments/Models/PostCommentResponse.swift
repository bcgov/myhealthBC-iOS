//
//  PostCommentResponse.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-28.
//

import Foundation

struct PostCommentResponse: Codable {
    let resourcePayload: PostCommentResponsePayload?
    let totalResultCount, pageIndex, pageSize: JSONNull?
    let resultStatus: Int?
    let resultError: ResultError?
}

// MARK: - ResourcePayload
struct PostCommentResponsePayload: Codable {
    let id, userProfileID, text, entryTypeCode: String?
    let parentEntryID: String?
    let version: Int?
    let createdDateTime, createdBy, updatedDateTime, updatedBy: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userProfileID = "userProfileId"
        case text, entryTypeCode
        case parentEntryID = "parentEntryId"
        case version, createdDateTime, createdBy, updatedDateTime, updatedBy
    }
}

typealias PostCommentResponseResult = PostCommentResponsePayload
