//
//  AuthenticatedNotificationResponse.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-05-31.
//

import Foundation

struct AuthenticatedNotificationResponseElement: Codable {
    let id: String
    let categoryName, displayText: String?
    let actionURL: String?
    let actionType: ActionType?
    let scheduledDateTimeUTC: String?

    enum CodingKeys: String, CodingKey {
        case id, categoryName, displayText
        case actionURL = "actionUrl"
        case actionType
        case scheduledDateTimeUTC = "scheduledDateTimeUtc"
    }
}

enum ActionType: String, Codable {
    case externalLink = "ExternalLink"
    case internalLink = "InternalLink"
    case none = "None"
}

typealias AuthenticatedNotificationResponse = [AuthenticatedNotificationResponseElement]
