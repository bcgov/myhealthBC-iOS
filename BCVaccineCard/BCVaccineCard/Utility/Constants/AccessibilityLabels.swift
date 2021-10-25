//
//  AccessibilityLabels.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-27.
//

import Foundation

struct AccessibilityLabels {
    
    struct MyHealthPassesScreen {
        static let navRightIconTitle = "Settings Icon"
        static let navRightIconHint = "Tapping this button will bring you to the settings screen"
    }
    
    struct HealthGatewayScreen {
        static let navRightIconTitle = "Help Icon"
        static let navRightIconHint = "Tapping this button will bring you to a help screen to assist you with the Health Gateway vaccine card retrieval method"
    }
    
    struct CovidVaccineCardsScreen {
        static let navRightIconTitle = "Add Card"
        static let navRightIconHint = "Tapping this button will bring you to a new screen with different options to retrieve your QR code"
    }
    
    struct Navigation {
        static let backButtonTitle = "Navigation bar back button"
        static let backButtonHint = "Tapping this button will take you back to "
    }
    
    struct Onboarding {
        static let buttonNextTitle = "Next"
        static let buttonNextHint = "Tapping this button will take you to the introduction of the next feature"
        static let buttonGetStartedTitle = "Get Started"
        static let buttonGetStartedHint = "Tapping this button will take you to the Health Passes home screen"
        static let buttonOkTitle = "Okay"
        static let buttonOkHint = "Tapping this button will take you to the Health Passes home screen"
    }
    
    struct QRMethods {
        static let scanWithCamera = "Tapping this button will open your camera to scan a QR code."
        static let uploadImage = "Tapping this button will open your camera roll to select a QR code that you've saved."
        static let enterGatewayInfo = "Tapping this button will take you to a new screen where you can enter your personal health information to fetch your vaccine card from health gateway"
    }
    
    struct NoCards {
        static let addCardLabel = "Add Card"
        static let addCardHint = "Tapping this button will bring you to a new screen with different options to retrieve your QR code"
    }
    
    struct AddCard {
        static let addCardLabel = "Add Card"
        static let addCardHint = "Tap this button to add a vaccine card"
    }
    
    struct ViewAllButton {
        static let viewAllLabel = "View All"
        static let viewAllHint = "Tapping this button will show you all of your saved covid 19 vaccine cards"
    }
}

