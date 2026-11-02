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
    let totalResultCount, pageIndex, pageSize: Int?
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
    let totalResultCount, pageIndex, pageSize: Int?
    let resultError: ResultError?
}

// MARK: - RemoteDependent
struct RemoteDependent: Codable {
    let dependentInformation: DependentInformation?
    let ownerID, delegateID, expiryDate: String?
    let totalDelegateCount, reasonCode, version: Int?

    enum CodingKeys: String, CodingKey {
        case dependentInformation
        case ownerID = "ownerId"
        case delegateID = "delegateId"
        case expiryDate, totalDelegateCount, reasonCode, version
    }
}


extension Dependent {
    func toRemote(totalDelegateCount: Int, expiryDate: Date?) -> RemoteDependent? {
        guard let patient = info else {return nil}
        return RemoteDependent(dependentInformation: DependentInformation(hdid: patient.hdid, firstname: patient.firstName, lastname: patient.lastName, phn: patient.phn, dateOfBirth: patient.birthday?.yearMonthDayString, gender: patient.gender), ownerID: ownerID, delegateID: delegateID, expiryDate: expiryDate?.yearMonthDayString, totalDelegateCount: totalDelegateCount, reasonCode: Int(reasonCode), version: Int(version))
    }
}
