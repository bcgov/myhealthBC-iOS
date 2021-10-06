//
//  Constants.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import Foundation
import UIKit

struct Constants {
    
    struct DateConstants {
        static let firstVaxDate = Date.Formatter.longDate.date(from: "January 1, 2020")
    }
    
    struct PrivacyPolicy {
        static let urlString = "https://www2.gov.bc.ca/gov/content/covid-19/vaccine/proof/businesses#app-privacy-policy"
    }
}
