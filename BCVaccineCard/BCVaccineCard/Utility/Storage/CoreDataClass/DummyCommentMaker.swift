//
//  dummyCommentMaker.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-07.
//

import Foundation
class DummyComments {
    static func getComment() -> Comment {
        let c = Comment(context: StorageService.shared.managedContext!)
        c.createdDateTime = Date()
        c.entryTypeCode = "1"
        c.id = "1"
        c.parentEntryID = "1"
        c.text = "this is my comment about things"
        c.updatedBy = "1"
        c.updatedDateTime = Date()
        c.userProfileID = "1"
        c.version = 1
        c.createdBy = "Me"
        return c
    }
}
