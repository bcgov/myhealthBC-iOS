//
//  Constants.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import Foundation
import UIKit

struct Constants {
    
    /// Authorization Header Key
    static let authorizationHeaderKey = "Authorization"
    
    struct DateConstants {
        static let firstVaxDate = Date.Formatter.yearMonthDay.date(from: "2020-01-01")
    }
    
    struct PrivacyPolicy {
        static let urlString = "https://www.healthgateway.gov.bc.ca/termsofservice"
    }
    
    struct Help {
        static let urlString = "https://www2.gov.bc.ca/gov/content/covid-19/vaccine/proof#help"
    }
    
    struct QueueItStrings {
        static let queueittoken = "queueittoken"
    }
    
    struct GatewayVaccineCardRequestParameters {
        static let phn = "phn"
        static let dateOfBirth = "dateOfBirth"
        static let dateOfVaccine = "dateOfVaccine"
    }
    
    struct KeychainPHNKey {
        static let key = "PHNKey" // Note: Data should be an array of 
    }
}
