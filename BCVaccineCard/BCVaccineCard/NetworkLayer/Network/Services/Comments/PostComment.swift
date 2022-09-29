//
//  PostCommentModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-06.
//

import Foundation

//struct PostComment: Codable {
//    let text, parentEntryID: String
//    let id, userProfileID, entryTypeCode: String?
//    let version: Int
//    let createdDateTime, createdBy, updatedDateTime, updatedBy: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userProfileID = "userProfileId"
//        case text, entryTypeCode
//        case parentEntryID = "parentEntryId"
//        case version, createdDateTime, createdBy, updatedDateTime, updatedBy
//    }
//}


struct PostComment: Codable {
    let text, parentEntryID, createdDateTime: String
    let userProfileID, entryTypeCode: String
    enum CodingKeys: String, CodingKey {
        case userProfileID = "userProfileId"
        case text, entryTypeCode, createdDateTime
        case parentEntryID = "parentEntryId"
    }
}
