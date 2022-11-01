//
//  DependentResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-18.
//

import Foundation

// MARK: - DependentsResponse
struct DependentsResponse: Codable {
    let resourcePayload: [RemoteDependent]?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
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
    let resourcePayload: RemoteDependent?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
}

// MARK: - RemoteDependent
struct RemoteDependent: Codable {
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


extension Dependent {
    func toRemote() -> RemoteDependent? {
        guard let patient = info else {return nil}
        return RemoteDependent(dependentInformation: DependentInformation(hdid: patient.hdid, firstname: patient.firstName, lastname: patient.lastName, phn: patient.phn, dateOfBirth: patient.birthday?.postServerDateTime, gender: patient.gender), ownerID: ownerID, delegateID: delegateID, reasonCode: Int(reasonCode), version: Int(version))
    }
}
