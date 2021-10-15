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
    /// Text used throughout app
    static var myCards: String { return "MyCards".localized }
    static var settings: String { return "Settings".localized }
    static var healthPass: String { return "HealthPass".localized }
    static var passes: String { return "Passes".localized }
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
    static var unsupportedDeviceTitle: String { return "UnsupportedDeviceTitle".localized }
    static var unsupportedDeviceVideoMessage: String { return "UnsupportedDeviceVideoMessage".localized }
    static var unsupportedDeviceQRMessage: String { return "UnsupportedDeviceQRMessage".localized }
    
    // Onboarding flow
    /// initial onboarding screen
    static var healthPasses: String { return "HealthPasses".localized }
    static var healthResources: String { return "HealthResources".localized }
    static var newsFeed: String { return "NewsFeed".localized }
    static var initialOnboardingOneDescription: String { return "InitialOnboardingOneDescription".localized }
    static var initialOnboardingTwoDescription: String { return "InitialOnboardingTwoDescription".localized }
    static var initialOnboardingThreeDescription: String { return "InitialOnboardingThreeDescription".localized }
    
    // Gateway screen
    /// Validation
    static var phnRequired: String { return "PHNRequired".localized }
    static var phnLength: String { return "PHNLength".localized }
    static var phnNumber: String { return "PHNNumber".localized }
    static var dobRequired: String { return "DOBRequired".localized }
    static var dovRequired: String { return "DOVRequired".localized }
    static var validDate: String { return "ValidDate".localized }
    static var dobRange: String { return "DOBRange".localized }
    static var dovRange: String { return "DOVRange".localized }
    /// Labels and other text
    static var formTitle: String { return "FormTitle".localized }
    static var addABCVaccineCard: String { return "AddABCVaccineCard".localized }
    static var formDescription: String { return "FormDescription".localized }
    static var personalHealthNumber: String { return "PersonalHealthNumber".localized }
    static var dateOfBirth: String { return "DateOfBirth".localized }
    static var dateOfVaccine: String { return "DateOfVaccine".localized }
    static var dose1OrDose2: String { return "Dose1OrDose2".localized }
    static var privacyStatement: String { return "PrivacyStatement".localized }
    
    // Health Pass Home screen
    static var covidVaccineCards: String { return "CovidVaccineCards".localized }
    static func passCount(count: String) -> String {
        return String(format: "PassCount".localized, count)
    }
    
    // My Cards screen
    static var bcVaccineCards: String { return "BCVaccineCards".localized }
    static var noCardsYet: String { return "NoCardsYet".localized }
    static var noCardsIntroText: String { return "NoCardsIntroText".localized }
    static var vaccinated: String { return "Vaccinated".localized }
    static var partiallyVaccinated: String { return "PartiallyVaccinated".localized }
    static var noRecordFound: String { return "NoRecordFound".localized }
    static var issuedOn: String { return "IssuedOn".localized }
    static var tapToZoomIn: String { return "TapToZoomIn".localized }
    static var presentForScanning: String { return "PresentForScanning".localized }
    static var unlinkCardTitle: String { return "UnlinkCardTitle".localized }
    static var unlinkCardMessage: String { return "UnlinkCardMessage".localized }
    
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
    static var resourceDescriptionText: String { return "ResourceDescriptionText".localized }
    static var getVaccinatedResource: String { return "GetVaccinatedResource".localized }
    static var getTestedResource: String { return "GetTestedResource".localized }
    static var getTestkitResource: String { return "GetTestkitResource".localized }
    
    
    
    // News Feed screen
    /// Already have newsFeed string from onboarding flow
    
    
}

// Accessibility only localized strings
extension String {
    
}

