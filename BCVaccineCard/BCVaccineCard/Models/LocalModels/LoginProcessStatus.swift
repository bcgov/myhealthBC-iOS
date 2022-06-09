//
//  LoginProcessStatus.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-25.
//

import Foundation

struct LoginProcessStatus: Codable {
    var hasStartedLoginProcess: Bool
    var hasCompletedLoginProcess: Bool
    var hasFinishedFetchingRecords: Bool
    var loggedInUserAuthManagerDisplayName: String?
}
