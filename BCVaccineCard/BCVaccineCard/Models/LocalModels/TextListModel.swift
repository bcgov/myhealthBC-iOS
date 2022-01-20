//
//  TextListModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
//

import UIKit

struct TextListModel: Codable {
    var header: TextProperties
    var subtext: TextProperties?
    
    struct TextProperties: Codable {
        var text: String
        var bolded: Bool
        var fontSize: CGFloat = 17.0
        var links: [LinkedStrings]? = nil
    }
}

