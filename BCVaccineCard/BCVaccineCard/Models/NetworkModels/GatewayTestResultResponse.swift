//
//  GatewayTestResultResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import Foundation

struct GatewayTestResultResponse: Codable {
    let patientDisplayName: String?
    let lab: String?
    let reportId: String?
    let collectionDateTime: Date?
    let resultDateTime: Date?
    let testName: String?
    let testType: String?
    let testStatus: String? // I'm assuming this will be equal to the enum that I created in the CovidTestResultModel
    let testOutcome: String? // Could also be here too??
    let resultTitle: String?
    let resultDescription: String?
    let resultLink: String?
}
