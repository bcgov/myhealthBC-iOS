//
//  AuthenticatedUserProfileResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-24.
//

import Foundation

// NOTE: For now, we really only need the hdId and acceptedTermsOfService fields - so that's all we're going to decode
struct AuthenticatedUserProfileResponseObject: Codable {
    let resourcePayload: ResourcePayload?
}

extension AuthenticatedUserProfileResponseObject {
    // MARK: - Profile
    struct ResourcePayload: Codable {
        let createdBy, createdDateTime, updatedBy, updatedDateTime: String?
        let version: Int?
        let acceptedTermsOfService: Bool?
        let hdID, termsOfServiceID: String?
        let email, smsNumber, closedDateTime, identityManagementID: String?
        let lastLoginDateTime, encryptionKey: String?
        let verifications: [Verification]?
        let isEmailVerified, isSMSNumberVerified: Bool
        let preferences: Preferences?
        
        enum CodingKeys: String, CodingKey {
            case createdBy, createdDateTime, updatedBy, updatedDateTime, version
            case hdID = "hdId"
            case acceptedTermsOfService
            case termsOfServiceID = "termsOfServiceId"
            case email, smsNumber, closedDateTime
            case identityManagementID = "identityManagementId"
            case lastLoginDateTime, encryptionKey, verifications
            case isEmailVerified, isSMSNumberVerified
            case preferences
        }
    }
    
    // MARK: - TermsOfService
    struct TermsOfService: Codable {
        let createdBy, createdDateTime, updatedBy, updatedDateTime: String
        let version: Int
        let id: String
        let legalAgreementCode: Int
        let legalText, effectiveDate: String
    }
    
    // MARK: - Verification
    struct Verification: Codable {
        let createdBy, createdDateTime, updatedBy, updatedDateTime: String
        let version: Int
        let id, userProfileID: String
        let validated: Bool
        let emailID: String
        let email: Email
        let inviteKey, verificationType, smsNumber, smsValidationCode: String
        let expireDate: String
        let verificationAttempts: Int
        let deleted: Bool
        
        enum CodingKeys: String, CodingKey {
            case createdBy, createdDateTime, updatedBy, updatedDateTime, version, id
            case userProfileID = "userProfileId"
            case validated
            case emailID = "emailId"
            case email, inviteKey, verificationType, smsNumber, smsValidationCode, expireDate, verificationAttempts, deleted
        }
    }
    
    // MARK: - Email
    struct Email: Codable {
        let createdBy, createdDateTime, updatedBy, updatedDateTime: String
        let version: Int
        let id, from, to, subject: String
        let body: String
        let formatCode, priority: Int
        let sentDateTime, lastRetryDateTime: String
        let attempts, smtpStatusCode, emailStatusCode: Int
    }
    
    // MARK: - Preferences
    struct Preferences: Codable {
        let tutorialMenuNote, tutorialMenuExport, tutorialAddDependent, tutorialAddQuickLink, tutorialTimelineFilter, quickLinks: QuickLinks
        
        enum CodingKeys: String, CodingKey {
            case tutorialMenuNote, tutorialMenuExport, tutorialAddDependent, tutorialAddQuickLink, tutorialTimelineFilter, quickLinks
        }
    }

    // MARK: - QuickLinks
    struct QuickLinks: Codable {
        let hdID, preference, value: String?
        let version: Int?
        let createdDateTime, createdBy, updatedDateTime, updatedBy: String?

        enum CodingKeys: String, CodingKey {
            case hdID = "hdId"
            case preference, value, version, createdDateTime, createdBy, updatedDateTime, updatedBy
        }
    }
}

struct AuthenticatedUserProfileRequestObject: Codable {
    let profile: ResourcePayload
    
    // MARK: ResourcePayload
    struct ResourcePayload: Codable {
        let hdid: String
        let termsOfServiceId: String
        
        enum CodingKeys: String, CodingKey {
            case hdid = "hdId"
            case termsOfServiceId
        }
    }
}

struct QuickLinksPreference: Codable {
    struct Filter: Codable {
        let modules: [String]
    }
    enum Name: String, Codable {
        case MyNotes = "My Notes"
        case Immunization = "Immunization"
        case Medications = "Medications"
        case LabResults = "Lab Results"
        case SpecialAuthority = "Special authority"
        case HealthVisit = "Health visit"
        case ClinicalDocuments = "Clinical documents"
        case OrganDonor = "Organ donor"
        
        enum Section: Codable {
            case HealthRecord
            case Service
        }
        
        var getSection: Section {
            switch self {
            case .MyNotes, .Immunization, .Medications, .LabResults, .SpecialAuthority, .HealthVisit, .ClinicalDocuments: return .HealthRecord
            case .OrganDonor: return .Service
            }
        }
    }

    enum Section: Codable {
        case HealthRecord
        case Service
    }
    
    let name: Name
    let filter: Filter    
}

