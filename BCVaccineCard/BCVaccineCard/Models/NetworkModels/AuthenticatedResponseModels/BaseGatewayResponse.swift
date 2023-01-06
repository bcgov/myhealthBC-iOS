//
//  BaseGatewayResponse.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

protocol BaseGatewayResponse {
    var totalResultCount: Int? { get set }
    var pageIndex: Int? { get set }
    var pageSize: Int? { get set }
    var resultStatus: Int? { get set }
    var resultError: ResultError? { get set }
}
