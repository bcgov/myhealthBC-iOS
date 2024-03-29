//
//  PostCommentModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-06.
//

import Foundation

enum UnsynchedCommentMethod: String, Codable {
    case post
    case edit
    case delete
}

struct PostComment: Codable {
    let text, parentEntryID, userProfileID: String
    let entryTypeCode: String
    let createdDateTime: String

    enum CodingKeys: String, CodingKey {
        case text
        case parentEntryID = "parentEntryId"
        case userProfileID = "userProfileId"
        case entryTypeCode
        case createdDateTime
    }
}

struct DeleteComment: Codable {
    let id, text, parentEntryID, userProfileID: String
    let entryTypeCode: String
    let version: Int

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case parentEntryID = "parentEntryId"
        case userProfileID = "userProfileId"
        case entryTypeCode
        case version
    }
}

struct EditComment: Codable {
    let id, text, parentEntryID, userProfileID: String
    let entryTypeCode: String
    let version: Int
    let createdDateTime, createdBy, updatedDateTime, updatedBy: String

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case parentEntryID = "parentEntryId"
        case userProfileID = "userProfileId"
        case entryTypeCode
        case version
        case createdDateTime
        case createdBy
        case updatedDateTime
        case updatedBy
    }
}

