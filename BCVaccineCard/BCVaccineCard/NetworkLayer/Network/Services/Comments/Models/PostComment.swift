//
//  PostCommentModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-06.
//

import Foundation

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
