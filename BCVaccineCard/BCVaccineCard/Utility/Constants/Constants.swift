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
    
    static func onBoardingScreenLatestVersion(for type: OnboardingScreenType) -> Int {
        switch type {
        case .healthPasses:
            return 1
        case .healthRecords:
            return 1
        case .healthResources:
            return 1
        case .newsFeed:
            return 1
        }
    }
    
    struct DateConstants {
        static let firstVaxDate = Date.Formatter.yearMonthDay.date(from: "2020-01-01")
        static let firstTestDate = Date.Formatter.yearMonthDay.date(from: "2019-11-01")
    }
    
    struct PrivacyPolicy {
        static let urlString = "https://www2.gov.bc.ca/gov/content/health/managing-your-health/health-gateway/myhealth-app-privacy"
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
    
    struct GatewayTestResultsRequestParameters {
        static let phn = "phn"
        static let dateOfBirth = "dateOfBirth"
        static let collectionDate = "collectionDate"
    }
    
    struct AuthenticationHeaderKeys {
        static let authToken = "Authorization"
        static let hdid = "hdid"
    }
    
    struct KeychainPHNKey {
        static let key = "PHNKey" // Note: Data should be an array of
    }
    
    struct NetworkRetryAttempts {
        static let publicVaccineStatusRetryMaxForFedPass = 3
        static let publicRetryMaxForTestResults = 3
        static let publicRetryMaxForMedicationStatement = 3
        static let publicRetryMaxForLaboratoryOrders = 3
    }
    
    static let vaccineTable: [VaccineTable] = [
        VaccineTable(snowMedCode: 28581000087106, cvx: 208, mvx: "PFR", displayName: "PFIZER-BIONTECH COMIRNATY COVID-19"),
        VaccineTable(snowMedCode: 28571000087109, cvx: 207, mvx: "MOD", displayName: "MODERNA SPIKEVAX COVID-19"),
        VaccineTable(snowMedCode: 28761000087108, cvx: 210, mvx: "ASZ", displayName: "ASTRAZENECA VAXZEVRIA COVID-19"),
        VaccineTable(snowMedCode: 28961000087105, cvx: 210, mvx: "ASZ", displayName: "COVISHIELD COVID-19"),
        VaccineTable(snowMedCode: 28951000087107, cvx: 212, mvx: "JSN", displayName: "JANSSEN (JOHNSON & JOHNSON) COVID-19"),
        VaccineTable(snowMedCode: 29171000087106, cvx: 211, mvx: "NVX", displayName: "NOVAVAX COVID-19"),
        VaccineTable(snowMedCode: 31431000087100, cvx: 506, mvx: "UNK", displayName: "CANSINOBIO COVID-19"),
        VaccineTable(snowMedCode: 31341000087103, cvx: 505, mvx: "UNK", displayName: "SPUTNIK V COVID-19"),
        VaccineTable(snowMedCode: 31311000087104, cvx: 511, mvx: "SNV", displayName: "SINOVAC-CORONAVAC COVID-19"),
        VaccineTable(snowMedCode: 31301000087101, cvx: 510, mvx: "SPH", displayName: "SINOPHARM COVID-19")
    ]
}

extension Constants {
    public static func vaccineInfo(snowMedCode: Int) -> VaccineTable? {
        guard let table = vaccineTable.first(where: {$0.snowMedCode == snowMedCode}) else {
            return VaccineTable(snowMedCode: 0, cvx: 500, mvx: "UNK", displayName: "UNSPECIFIED COVID-19 VACCINE / VACCIN CONTRE LA COVID-19 NON")
        }
        return table
    }
    
    public  static func vaccineInfo(cvx: Int) -> VaccineTable? {
        guard let table = vaccineTable.first(where: {$0.cvx == cvx}) else {
            return VaccineTable(snowMedCode: 0, cvx: 500, mvx: "UNK", displayName: "UNSPECIFIED COVID-19 VACCINE / VACCIN CONTRE LA COVID-19 NON")
        }
        return table
    }
}
