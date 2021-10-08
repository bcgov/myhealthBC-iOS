//
//  ErrorResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//
// TODO: Clean this up for our purposes
import Foundation

protocol UnknownCaseRepresentable: RawRepresentable, CaseIterable where RawValue: Equatable {
    static var unknownCase: Self { get }
}

struct ErrorResponse: Decodable, LocalizedError {
    let errorType: ApiErrorType
    let errorMessage: String
    let errorDetails: ErrorDetails?
    var errorDescription: String? { errorMessage }
}

struct ErrorDetails: Decodable {
    let exceptionMessage: ExceptionMessage?
}

struct ExceptionMessage: Decodable {
    let en: String?
    let fr: String?
}

enum ApiErrorType: String, Decodable {
    // FIXME: Need to use errors that are applicable for this project
    case internalError = "INTERNAL_ERROR"
    case invalidSession = "INVALID_SESSION"
    case invalidSessionToken = "INVALID_SESSION_TOKEN"
    case invalidCredential = "INVALID_CREDENTIAL"
    case invalidCode = "INVALID_CODE"
    case failedFieldValidation = "FAILED_FIELD_VALIDATION"
    case accountLocked = "ACCOUNT_LOCKED"
    case passwordExpired = "PASSWORD_EXPIRED"
    case userDeactivated = "USER_DEACTIVATED"
    case unexpectedError
}

extension UnknownCaseRepresentable {
    init(rawValue: RawValue) {
        let value = Self.allCases.first(where: { $0.rawValue == rawValue })
        self = value ?? Self.unknownCase
    }
}

extension ApiErrorType: UnknownCaseRepresentable {
    static let unknownCase: ApiErrorType = .unexpectedError
}
