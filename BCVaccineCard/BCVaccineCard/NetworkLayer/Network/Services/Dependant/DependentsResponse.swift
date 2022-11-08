//
//  DependentResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-18.
//

import Foundation

// MARK: - DependentsResponse
struct DependentsResponse: Codable {
    let resourcePayload: [ResourcePayload]?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let dependentInformation: DependentInformation?
        let ownerID, delegateID: String?
        let reasonCode, version: Int?

        enum CodingKeys: String, CodingKey {
            case dependentInformation
            case ownerID = "ownerId"
            case delegateID = "delegateId"
            case reasonCode, version
        }
    }
}

// MARK: - DependentInformation
struct DependentInformation: Codable {
    let hdid, firstname, lastname, phn, dateOfBirth, gender: String?

    enum CodingKeys: String, CodingKey {
        case hdid, firstname, lastname, dateOfBirth, gender
        case phn = "PHN"
    }
}


// MARK: - AddDependentResponse
struct AddDependentResponse: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let dependentInformation: DependentInformation?
        let ownerID, delegateID: String?
        let reasonCode, version: Int?

        enum CodingKeys: String, CodingKey {
            case dependentInformation
            case ownerID = "ownerId"
            case delegateID = "delegateId"
            case reasonCode, version
        }
    }
}



typealias RemoteDependents = DependentsResponse.ResourcePayload
typealias RemoteDependent = AddDependentResponse.ResourcePayload




