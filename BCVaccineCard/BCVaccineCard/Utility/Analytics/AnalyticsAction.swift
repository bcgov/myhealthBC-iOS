//
//  AnalyticsAction.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-19.
//

import Foundation


enum AnalyticsAction: String {
    case AddQR = "add_qr"
    case RemoveCard = "remove_card"
    case ResoruceLinkSelected = "resource_click"
    case NewsLinkSelected = "news_feed_selected"
}

enum AnalyticsText: String {
    case Scan = "Scan"
    case Upload = "Upload"
    case Get = "Get"
}
