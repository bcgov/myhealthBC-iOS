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
    case Download = "Download"
}

enum AnalyticsText: String {
    case Scan = "Scan"
    case Upload = "Upload"
    case Get = "Get"
    case Document = "Document"
}

struct AnalyticsAdditionalProperties {
    
    enum AnalyticsAdditionalPropertiesKeys: String {
        case dataset = "dataset"
        case type = "type"
        case format = "format"
        case actor = "actor"
    }
    
    enum AnalyticsAdditionalPropertiesValues: String {
        case bcCancer = "BC Cancer"
        case result = "Result"
        case recall = "Recall"
        case pdf = "PDF"
        case user = "User"
    }
    
    let key: AnalyticsAdditionalPropertiesKeys
    let value: AnalyticsAdditionalPropertiesValues
    
}
