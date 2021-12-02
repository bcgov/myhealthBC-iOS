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
    
    struct KeychainPHNKey {
        static let key = "PHNKey" // Note: Data should be an array of 
    }
    
    struct NetworkRetryAttempts {
        static let publicVaccineStatusRetryMaxForFedPass = 3
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

// MARK: Dummy Data - delete once network request for test results is implemented
extension Constants {
    private static let gatewayResponsePending = GatewayTestResultResponse(patientDisplayName: "Kevin Malone", lab: "Chilli City", reportId: "DGNAGANGAGPIANGN", collectionDateTime: Date(), resultDateTime: Date(), testName: "COVID-19 TEST", testType: "pending", testStatus: "pending", testOutcome: "", resultTitle: "", resultDescription: "", resultLink: "")
    private static let gatewayResponseNegative = GatewayTestResultResponse(patientDisplayName: "John Daley", lab: "Illinois", reportId: "GGNAGSDGDSIANGN", collectionDateTime: Date(), resultDateTime: Date(), testName: "COVID-19 TEST", testType: "negative", testStatus: "negative", testOutcome: "", resultTitle: "", resultDescription: "", resultLink: "")
    private static let gatewayResponsePositive = GatewayTestResultResponse(patientDisplayName: "Magic Johnson", lab: "LA", reportId: "HGNAGANGONONAGGN", collectionDateTime: Date(), resultDateTime: Date(), testName: "COVID-19 TEST", testType: "positive", testStatus: "positive", testOutcome: "", resultTitle: "", resultDescription: "", resultLink: "")
    private static let gatewayResponseIndeterminate = GatewayTestResultResponse(patientDisplayName: "Michael Scott", lab: "Dunder Mifflin", reportId: "RGNAIETAGPIANGN", collectionDateTime: Date(), resultDateTime: Date(), testName: "COVID-19 TEST", testType: "indeterminate", testStatus: "indeterminate", testOutcome: "", resultTitle: "", resultDescription: "", resultLink: "")
    private static let gatewayResponseCancelled = GatewayTestResultResponse(patientDisplayName: "Seth Rogan", lab: "California", reportId: "BGAEGAGNGPIANGN", collectionDateTime: Date(), resultDateTime: Date(), testName: "COVID-19 TEST", testType: "cancelled", testStatus: "cancelled", testOutcome: "", resultTitle: "", resultDescription: "", resultLink: "")
    
    static let testResultsDummyData: [TestDummyData] = [
        TestDummyData(data: LocallyStoredCovidTestResultModel(response: gatewayResponsePending, status: .pending), phn: "111111111"),
        TestDummyData(data: LocallyStoredCovidTestResultModel(response: gatewayResponseNegative, status: .negative), phn: "222222222"),
        TestDummyData(data: LocallyStoredCovidTestResultModel(response: gatewayResponsePositive, status: .positive), phn: "333333333"),
        TestDummyData(data: LocallyStoredCovidTestResultModel(response: gatewayResponseIndeterminate, status: .indeterminate), phn: "444444444"),
        TestDummyData(data: LocallyStoredCovidTestResultModel(response: gatewayResponseCancelled, status: .cancelled), phn: "555555555")
    ]
}

struct TestDummyData {
    let data: LocallyStoredCovidTestResultModel
    let phn: String
}
