//
//  Strings.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-05.
//

import UIKit

// Localized strings
extension String {
    // General
    /// Generic text
    static var ok: String { return "OK".localized }
    static var yes: String { return "Yes".localized }
    static var no: String { return "No".localized }
    static var edit: String { return "Edit".localized }
    static var delete: String { return "Delete".localized }
    /// Text used throughout app
    static var myCards: String { return "MyCards".localized }
    static var settings: String { return "Settings".localized }
    static var healthPass: String { return "HealthPass".localized }
    static var passes: String { return "Passes".localized }
    static var records: String { return "Records".localized }
    /// Button titles
    static var cancel: String { return "Cancel".localized }
//    static var enter: String { return "Enter".localized }
    static var submit: String { return "Submit".localized }
    static var done: String { return "Done".localized }
    static var saveACopy: String { return "SaveACopy".localized }
    static var close: String { return "Close".localized }
    static var manageCards: String { return "ManageCards".localized }
//    static var plusAddCard: String { return "PlusAddCard".localized }
    static var addCard: String { return "AddCard".localized }
    static var next: String { return "Next".localized }
    static var viewAll: String { return "ViewAll".localized }
    static var getStarted: String { return "GetStarted".localized }
    
    // Errors
    static var noCameraAccessTitle: String { return "NoCameraAccessTitle".localized }
    static var noCameraAccessMessage: String { return "NoCameraAccessMessage".localized }
    static var multipleQRCodesMessage: String { return "MultipleQRCodesMessage".localized }
    static var invalidQRCodeMessage: String { return "InvalidQRCodeMessage".localized }
    static var noQRFound: String { return "NoQRFound".localized }
    static var multipleQRCodesTitle: String { return "MultipleQRCodesTitle".localized }
    static var onlyOneQRCodeMessage: String { return "OnlyOneQRCodeMessage".localized }
    static var unsupportedDeviceTitle: String { return "UnsupportedDeviceTitle".localized }
    static var unsupportedDeviceVideoMessage: String { return "UnsupportedDeviceVideoMessage".localized }
    static var unsupportedDeviceQRMessage: String { return "UnsupportedDeviceQRMessage".localized }
    static var error: String { return "Error".localized }
    static var theInformationDoesNotMatchTitle: String { return "TheInformationDoesNotMatchTitle".localized }
    static var theInformationDoesNotMatchDescription: String { return "TheInformationDoesNotMatchDescription".localized }
    static var networkUnavailableTitle: String { return "NetworkUnavailableTitle".localized }
    static var networkUnavailableMessage: String { return "NetworkUnavailableMessage".localized }
    static var inProgressErrorTitle: String { return "InProgressErrorTitle".localized }
    static var inProgressErrorMessage: String { return "InProgressErrorMessage".localized }
    static var unknownErrorMessage: String { return "UnknownErrorMessage".localized }
    static var genericErrorMessage: String { return "GenericErrorMessage".localized }
    static var queueItClosedTitle: String { return "QueueItClosedTitle".localized }
    static var queueItClosedMessage: String { return "QueueItClosedMessage".localized }
    static var errorParsingPHNFromHG: String { return "ErrorParsingPHNFromHG".localized }
    static var errorParsingPHNMessage: String { return "ErrorParsingPHNMessage".localized }
    static var duplicateTitle: String { return "DuplicateTitle".localized }
    static var duplicateMessage: String { return "DuplicateMessage".localized }
    static var duplicateTestMessage: String { return "DuplicateTestMessage".localized }
    static var duplicateMessageImsRecord: String { return "DuplicateMessageImsRecord".localized }
    static var healthGatewayError: String { return "HealthGatewayError".localized }
    
    // Alert
    static var vaxAddedBannerAlert: String { return "VaxAddedBannerAlert".localized }
    static var updatedCard: String {return "UpdatedCard".localized}
    static var updateCardFailed: String {return "UpdateCardFailed".localized}
    
    // Onboarding flow
    /// initial onboarding screen
    static var healthPasses: String { return "HealthPasses".localized }
    static var healthRecords: String { return "HealthRecords".localized }
    static var healthResources: String { return "HealthResources".localized }
    static var newsFeed: String { return "NewsFeed".localized }
    static var initialOnboardingHealthPassesDescription: String { return "InitialOnboardingHealthPassesDescription".localized }
    static var initialOnboardingHealthRecordsDescription: String { return "InitialOnboardingHealthRecordsDescription".localized }
    static var initialOnboardingHealthResourcesDescription: String { return "InitialOnboardingHealthResourcesDescription".localized }
    static var initialOnboardingNewsFeedDescription: String { return "InitialOnboardingNewsFeedDescription".localized }
    static var new: String { return "NEW".localized }
    
    // Gateway screen
    /// Validation
    static var phnRequired: String { return "PHNRequired".localized }
    static var phnLength: String { return "PHNLength".localized }
    static var phnNotValid: String { return "PHNNotValid".localized }
    static var phnNumber: String { return "PHNNumber".localized }
    static var dobRequired: String { return "DOBRequired".localized }
    static var dovRequired: String { return "DOVRequired".localized }
    static var dotRequired: String { return "DOTRequired".localized }
    static var validDate: String { return "ValidDate".localized }
    static var dobRange: String { return "DOBRange".localized }
    static var dovRange: String { return "DOVRange".localized }
    static var dotRange: String { return "DOVRange".localized }
    static var formTestNavTitle: String { return "AddCovid19TestResult".localized }
    static var formRecordNavTitle: String { return "AddABCVaccineRecord".localized }
    /// Labels and other text
//    static var formTitle: String { return "FormTitle".localized }
//    static var addABCVaccineCard: String { return "AddABCVaccineCard".localized }
    static var addAHealthRecord: String { return "AddAHealthRecord".localized }
    static var addAHealthPass: String { return "AddAHealthPass".localized }
    static var formDescription: String { return "FormDescription".localized }
    static var personalHealthNumber: String { return "PersonalHealthNumber".localized }
    static var dateOfBirth: String { return "DateOfBirth".localized }
    static var dateOfVaccine: String { return "DateOfVaccine".localized }
    static var anyDose: String { return "AnyDose".localized }
    static var dateOfTest: String{ return "DateOfTest".localized }
    static var phnFooter: String { return "PHNFooter".localized }
    static var gatewayPrivacyStatementDescription: String { return "GatewayPrivacyStatementDescription".localized }
    static var privacyPolicyStatement: String { return "PrivacyPolicyStatement".localized }
//    static var privacyPolicyStatement: String { return "PrivacyPolicyStatement".localized }
    static func privacyPolicyStatement(context: String) -> String {
        return String(format: "PrivacyPolicyStatement".localized, context)
    }
    static var privacyPolicyStatementEmail: String { return "PrivacyPolicyStatementEmail".localized }
    static var privacyPolicyStatementEmailLink: String { return "PrivacyPolicyStatementEmailLink".localized }
    static var privacyPolicyStatementPhoneNumber: String { return "PrivacyPolicyStatementPhoneNumber".localized }
    static var privacyPolicyStatementPhoneNumberLink: String { return "PrivacyPolicyStatementPhoneNumberLink".localized }
    static var privacyVaccineStatusText: String { return "PrivacyVaccineStatusText".localized }
    static var privacyTestResultText: String { return "PrivacyTestResultText".localized }
    static var rememberePHNandDOB: String { return "RememberPHNandDOB".localized }
    
    
    // Health Pass Home screen
    static var covidVaccineCards: String { return "CovidVaccineCards".localized }
    static func passCount(count: String) -> String {
        return String(format: "PassCount".localized, count)
    }
    
    // My Cards screen
    static var bcVaccineCards: String { return "BCVaccineCards".localized }
    static var bcVaccinePasses: String { return "BCVaccinePasses".localized }
    static var getFederalTravelPass: String { return "GetFederalTravelPass".localized }
    static var noCardsYet: String { return "NoCardsYet".localized }
    static var noCardsIntroText: String { return "NoCardsIntroText".localized }
//    static var vaccinePass: String { return "VaccinePass".localized }
    static var bcVaccineCard: String { return "BCVaccineCard".localized }
    static var bcVaccinePass: String { return "BCVaccinePass".localized }
    static var federalProofOfVaccination: String { return "FederalProofOfVaccination".localized }
    static var vaccinated: String { return "Vaccinated".localized }
    static var partiallyVaccinated: String { return "PartiallyVaccinated".localized }
    static var noRecordFound: String { return "NoRecordFound".localized }
    static var issuedOn: String { return "IssuedOn".localized }
    static var tapToZoomIn: String { return "TapToZoomIn".localized }
    static var presentForScanning: String { return "PresentForScanning".localized }
    static var unlinkCardTitle: String { return "UnlinkCardTitle".localized }
    static var unlinkCardMessage: String { return "UnlinkCardMessage".localized }
    static var noName: String { return "NoName".localized }
    static var showFederalProof: String { return "ShowFederalProof".localized }
    static var getFederalProof: String { return "GetFederalProof".localized }
    static var federalProofSubtitle: String { return "FederalProofSubtitle".localized }
    
    // QR Method Selection screen
    static var qrDescriptionText: String { return "QRDescriptionText".localized }
    static var cameraScanOption: String { return "CameraScanOption".localized }
    static var imageUploadOption: String { return "ImageUploadOption".localized }
    static var healthGatewayOption: String { return "HealthGatewayOption".localized }
    
    // Settings screen
    static var settingsOpeningText: String { return "SettingsOpeningText".localized }
    static var help: String { return "Help".localized }
    
    // Resource screen
    static var resource: String { return "Resource".localized }
    static var resources: String { return "Resources".localized }
    static var resourceDescriptionText: String { return "ResourceDescriptionText".localized }
    static var getVaccinatedResource: String { return "GetVaccinatedResource".localized }
    static var getTestedResource: String { return "GetTestedResource".localized }
    static var getTestkitResource: String { return "GetTestkitResource".localized }
    static var covid19SymptomCheckerResource: String { return "Covid19SymptomCheckerResource".localized }
    static var schoolRelatedResource: String { return "SchoolRelatedResource".localized }
    
    // Federal Paaa pdf
    static var travelPass: String { return "TravelPass".localized }
    static var canadianCOVID19ProofOfVaccination: String { return "CanadianCOVID19ProofOfVaccination".localized }

    static var updateCard: String { return "UpdateCard".localized }
    static var updateCardFor: String { return "UpdateCardFor".localized }
    // News Feed screen
    /// Already have newsFeed string from onboarding flow
    
    // MARK: Health Records
    static var getVaccinationRecordsTitle: String { return "GetVaccinationRecordsTitle".localized }
    static var getCovidTestResultsTitle: String { return "GetCovidTestResultsTitle".localized }
    static var getVaccinationRecordsDescription: String { return "GetVaccinationRecordsDescription".localized }
    static var getCovidTestResultsDescription: String { return "GetCovidTestResultsDescription".localized }
    static var covid19mRNATitle: String { return "Covid19mRNATitle".localized }
    static var covid19vaccination: String { return "Covid19vaccination".localized }
    static var covid19TestResultTitle: String { return "Covid19TestResultTitle".localized }
    static var vaccinationRecord: String { return "VaccinationRecord".localized }
    static var recordText: String { return "RecordText".localized }
    static var viewDetailsOfCovidRecordsText: String { return "ViewDetailsOfCovidRecordsText".localized }
    static var fetchHealthRecordsIntroText: String { return "FetchHealthRecordsIntroText".localized }
    static var deleteCovidHealthRecord: String { return "DeleteCovidHealthRecord".localized }
    static var deleteRecord: String { return "DeleteRecord".localized }
    static var deleteTestResult: String { return "DeleteTestResult".localized }
    static var deleteTestResultMessage: String { return "DeleteTestResultMessage".localized }
    static var cancelledTestRecordMessage: String { return "CancelledTestRecordMessage".localized }
    static var pendingTestRecordMessage: String { return "PendingTestRecordMessage".localized }
    static var instructions: String { return "Instructions".localized }
    static var instructionsMessage: String { return "InstructionsMessage".localized }
    
    // MARK: Statuses
    static var cancelled: String { return "Cancelled".localized }
    static var pending: String { return "Pending".localized }
    
    // MARK: Settings
    static var profileAndSettings: String { return "ProfileAndSettings".localized }
    static var viewProfile: String { return "ViewProfile".localized }
    static var bcscLogin: String { return "BcscLogin".localized }
    static var securityAndData: String { return "SecurityAndData".localized }
    static var privacyStatement: String { return "PrivacyStatement".localized }
    
    static var deleteAllRecordsAndSavedDataDescription: String { return "DeleteAllRecordsAndSavedDataDescription".localized }
    static var deleteAllRecordsAndSavedData: String { return "DeleteAllRecordsAndSavedData".localized }
    static var disableAnalytics: String { return "DisableAnalytics".localized }
    static var enableAnalytics: String { return "EnableAnalytics".localized }
    static var analytyticsUsageDescription: String { return "AnalytyticsUsageDescription".localized }
    static var deleteData: String { return "DeleteData".localized }
    static var confirmDeleteAllRecordsAndSaveData: String { return "ConfirmDeleteAllRecordsAndSaveData".localized }
    static var loginSuccess: String { return "LoginSuccess".localized }
    static var recordsWillBeAutomaticallyAdded: String { return "RecordsWillBeAutomaticallyAdded".localized }
    static var loginDescription: String { return "LoginDescription".localized }
    static var localAuthDescription: String { return "LocalAuthDescription".localized }
    static var touchId: String { return "TouchId".localized }
    static var logoutTitle: String { return "LogoutTitle".localized }
    static var logoutDescription: String { return "LogoutDescription".localized }
    static var logOut: String { return "LogOut".localized }
    static var reAuthenticateMessage: String { return "ReAuthenticateMessage".localized }
    static var deletedAllRecordsAndSavedData: String { return "DeletedAllRecordsAndSavedData".localized }
    
    // MARK: Local Auth
    static var localAuthPrivacyText: String { return "LocalAuthPrivacyText".localized }
    static var privacy: String { return "Privacy".localized }
    static var protectYourPersonalInformation: String { return "ProtectYourPersonalInformation".localized }
    static var localAuthViewDescription: String { return "LocalAuthViewDescription".localized }
    static var learnMoreAboutLocalAuth: String { return "LearnMoreAboutLocalAuth".localized }
    
    static var useTouchId: String { return "UseTouchId".localized }
    static var usePassCode: String { return "UsePassCode".localized }
    static var useFaceId: String { return "UseFaceId".localized }
    static var turnOnPasscode: String { return "TurnOnPasscode".localized }
    static var turnOnFaceId: String { return "TurnOnFaceId".localized }
    static var turnOnTouchId: String { return "TurnOnTouchId".localized }
    
}

// Accessibility only localized strings
extension String {
    
}

