//
//  ErrorResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//
import Foundation

// MARK: - ResultError
struct ResultError: Codable {
    let resultMessage: String?
    var errorCode: String? = nil
    var traceID: String? = nil
    var actionCode: String? = nil

    enum CodingKeys: String, CodingKey {
        case resultMessage, errorCode
        case traceID = "traceId"
        case actionCode
    }
}

extension ResultError: Error {
    
}

struct DisplayableResultError: Codable {
    let title: String
    let resultError: ResultError
}
