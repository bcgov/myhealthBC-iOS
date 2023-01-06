//
//  BaseGatewayResponse.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

protocol BaseGatewayResponse: KeyValueCoding {
    var totalResultCount: Int? { get set }
    var pageIndex: Int? { get set }
    var pageSize: Int? { get set }
    var resultStatus: Int? { get set }
    var resultError: ResultError? { get set }
}

protocol BaseRetryableGatewayResponse {
    var loaded: Bool? { get set }
    var retryin: Int? { get set }
}
