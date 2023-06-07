//
//  PostNote.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation

struct PostNote: Codable {
    let title: String
    let text: String
    let journalDate: String // "2023-06-07" - yyyy-mm-dd
}
