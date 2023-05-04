//
//  Constants.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import Foundation
import UIKit

struct Constants {
    
    struct Network {
        
#if PROD
        static let MobileConfig = URL(string: "https://healthgateway.gov.bc.ca/mobileconfiguration")!
#elseif TEST
        static let MobileConfig = URL(string: "https://test.healthgateway.gov.bc.ca/mobileconfiguration")!
#elseif DEV
        static let MobileConfig = URL(string: "https://dev.healthgateway.gov.bc.ca/mobileconfiguration")!
#endif
        
        struct NetworkRetryAttempts {
            static let maxRetry = 5
            static let retryIn: Int = 5
        }
        
        struct APIHeaders {
            static let authToken = "Authorization"
            static let hdid = "hdid"
            static let dependentHdid = "dependentHdid"
        }
    }
    
    struct BCSC {
        static let downloadURL = "https://apps.apple.com/us/app/id1234298467"
        static let scheme = "ca.bc.gov.id.servicescard://"
    }
    
    /// Authorization Header Key
    static let authorizationHeaderKey = "Authorization"
    
    static func onBoardingScreenLatestVersion(for type: OnboardingScreenType) -> Int {
        switch type {
        case .healthPasses:
            return 1
        case .healthRecords:
            return 2
        case .healthResources:
            return 1
//        case .newsFeed:
//            return 1
        case .dependents:
            return 1
        case .services:
            return 3
        }
    }
    
    struct DateConstants {
        static let firstVaxDate = Date.Formatter.yearMonthDay.date(from: "2020-01-01")
        static let firstTestDate = Date.Formatter.yearMonthDay.date(from: "2019-11-01")
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
    
    struct GatewayTestResultsRequestParameters {
        static let phn = "phn"
        static let dateOfBirth = "dateOfBirth"
        static let collectionDate = "collectionDate"
    }
    
    struct AuthenticationHeaderKeys {
        static let authToken = "Authorization"
        static let hdid = "hdid"
        static let dependentHdid = "dependentHdid"
        static let apiVersion = "api-version"
    }
    
    struct AuthenticatedMedicationStatementParameters {
        static let protectiveWord = "protectiveWord"
    }
    
    struct AuthenticatedUserProfileParameters {
        static let hdid = "hdId"
        static let acceptedTermsOfService = "acceptedTermsOfService"
    }
    
    struct KeychainPHNKey {
        static let key = "PHNKey" // Note: Data should be an array of
    }
    
    struct PDFDocumentName {
        static let name = "MyHealth Document.pdf"
    }
    
    struct AuthStatusKey {
        static let key = "AuthStatus"
    }
    
    struct SourceVCReloadKey {
        static let key = "source"
    }
    
    struct TermsOfServiceResponseKey {
        static let key = "accepted"
    }
    
    struct GenericErrorKey {
        static let key = "error"
        static let titleKey = "errorTitle"
    }
    
    struct AgeLimit {
        static let ageLimitForRecords = 12
    }
    
    struct NetworkRetryAttempts {
        static let maxRetry = 5
        static let retryIn: Int = 5
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

// MARK: Auth Issuer
extension Constants {
#if PROD
    static let authIssuer = "https://oidc.gov.bc.ca/auth/realms/ff09qn3f"
#elseif TEST
    static let authIssuer = "https://test.oidc.gov.bc.ca/auth/realms/ff09qn3f"
#elseif DEV
    static let authIssuer = "https://dev.oidc.gov.bc.ca/auth/realms/ff09qn3f"
#endif
}
