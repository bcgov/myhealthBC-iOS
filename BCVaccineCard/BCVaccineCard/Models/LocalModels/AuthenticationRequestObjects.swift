//
//  AuthenticationRequestObjects.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-19.
//

import Foundation

struct AuthenticationRequestObject: Codable {
    let authToken: String
    let hdid: String
    
    var bearerAuthToken: String {
        return "Bearer \(authToken)"
    }
}
