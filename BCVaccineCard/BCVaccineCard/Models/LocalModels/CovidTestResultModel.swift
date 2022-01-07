//
//  CovidTestResultModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import UIKit

enum CovidTestResult: String, Codable {
    case pending = "Pending"
    case negative = "Negative"
    case positive = "Positive"
    case indeterminate = "Indeterminate"
    case cancelled = "Cancelled"
    
    var getTitle: String {
        return self.rawValue.capitalized
    }
    
    // TODO: Include get color here (based on designs) to be used for Banner View for test results
    var getColor: UIColor {
        switch self {
        case .pending:
            return AppColours.CovidTest.pendingBackground
        case .negative:
            return AppColours.CovidTest.negativeBackground
        case .positive:
            return AppColours.CovidTest.positiveBackground
        case .indeterminate:
            return AppColours.CovidTest.indeterminateBackground
        case .cancelled:
            return AppColours.CovidTest.cancelledBackground
        }
    }
    
    var getResultTextColor: UIColor {
        switch self {
        case .pending:
            return AppColours.CovidTest.pendingText
        case .negative:
            return AppColours.CovidTest.negativeText
        case .positive:
            return AppColours.CovidTest.positiveText
        case .indeterminate:
            return AppColours.CovidTest.indeterminateText
        case .cancelled:
            return AppColours.CovidTest.cancelledText
        }
    }
}

// TODO: Will likely need to adjust this to what we need once we start testing with their actual endpoint
public struct LocallyStoredCovidTestResultModel: Codable, Equatable {
    // For now, just doing this until we actually test with their data to see what we really get (just have a lack of faith in their documentation is all)
    public static func == (lhs: LocallyStoredCovidTestResultModel, rhs: LocallyStoredCovidTestResultModel) -> Bool {
        if let rhsResponse = rhs.response?.resourcePayload, let lshResponse = lhs.response?.resourcePayload {
            return lshResponse.records.equals(other: rhsResponse.records)
        }
        return (rhs.response == nil && lhs.response == nil)
    }
    // TODO: Should likely convert this 'response' into a model that we can use
    let response: GatewayTestResultResponse?
    let resultType: CovidTestResult
}


extension LocallyStoredCovidTestResultModel {
    var testResults: [GatewayTestResultResponseRecord] {
        return response?.resourcePayload?.records ?? []
    }
}

//extension GatewayTestResultResponseRecord {
//    var status: CovidTestResult {

//         CovidTestResult.init(rawValue: self.testOutcome ?? "") ?? CovidTestResult.init(rawValue: self.testStatus ?? "") ?? .indeterminate
//    }
//}
