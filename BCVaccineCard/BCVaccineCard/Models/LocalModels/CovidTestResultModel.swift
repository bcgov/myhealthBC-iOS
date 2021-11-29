//
//  CovidTestResultModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import UIKit

enum CovidTestResult: String, Codable {
    case pending = "pending", negative, positive, indeterminate, cancelled
    
    var getTitle: String {
        return self.rawValue.uppercased()
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
    
    var getStatusTextColor: UIColor {
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
        guard let l = lhs.response?.reportId, let r = rhs.response?.reportId else { return false }
        return l == r
    }
    // TODO: Should likely convert this 'response' into a model that we can use
    let response: GatewayTestResultResponse?
    let status: CovidTestResult
}
