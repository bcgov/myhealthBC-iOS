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
    let errorCode: String? = nil
    let traceID: String? = nil
    let actionCode: String? = nil

    enum CodingKeys: String, CodingKey {
        case resultMessage, errorCode
        case traceID = "traceId"
        case actionCode
    }
}

extension ResultError: Error {
    
}
