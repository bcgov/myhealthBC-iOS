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
    let createdDateTime: String // Gateway Timezone
    var addedToTimeline: Bool
}
