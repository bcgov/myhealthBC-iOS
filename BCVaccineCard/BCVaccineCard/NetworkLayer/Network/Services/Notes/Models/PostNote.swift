//
//  PostNote.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation

struct PostNote: Codable {
    var title: String
    var text: String
    var journalDate: String // "2023-06-07" - yyyy-mm-dd
//    let createdDateTime: String // Gateway Timezone
    var addedToTimeline: Bool
}

struct UpdateNote: Codable {
    let id: String
    let hdid: String
    let title: String
    let text: String
    let journalDate: String // "2023-06-07" - yyyy-mm-dd
    let version: Int
    let createdDateTime: String // Gateway Timezone
    let createdBy: String
    let updatedDateTime: String // Gateway Timezone
    let updatedBy: String
    
    init(note: Note, updatedTitle: String?, updatedText: String?, updatedJournalDate: String?) {
        let defaultHDID = AuthManager().hdid ?? ""
        id = note.id ?? UUID().uuidString
        hdid = note.hdid ?? defaultHDID
        if let updatedTitle = updatedTitle {
            title = updatedTitle
        } else {
            title = note.title ?? ""
        }
        if let updatedText = updatedText {
            text = updatedText
        } else {
            text = note.text ?? ""
        }
        if let updatedJournalDate = updatedJournalDate {
            journalDate = updatedJournalDate
        } else {
            journalDate = note.journalDate?.yearMonthDayString ?? Date().yearMonthDayString
        }
        version = Int(note.version)
        createdDateTime = note.createdDateTime?.gatewayDateAndTimeWithMSAndTimeZone ?? Date().gatewayDateAndTimeWithMSAndTimeZone
        createdBy = note.hdid ?? defaultHDID
        updatedDateTime = note.updatedDateTime?.gatewayDateAndTimeWithMSAndTimeZone ?? Date().gatewayDateAndTimeWithMSAndTimeZone
        updatedBy = note.updatedBy ?? defaultHDID
    }
}
