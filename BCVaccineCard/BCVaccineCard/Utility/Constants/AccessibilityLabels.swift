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
        static let navLeftIconTitle = "Close Icon"
        static let navLeftIconHint = "Tapping this button will return you to the previous screen"
        static let navRightIconTitle = "Help Icon"
        static let navRightIconHint = "Tapping this button will bring you to a help screen to assist you with the Health Gateway vaccine card retrieval method"
    }
    
    struct CovidVaccineCardsScreen {
        static let navRightIconTitle = "Add Card"
        static let navRightIconHint = "Tapping this button will bring you to a new screen with different options to retrieve your QR code"
        static let inEditMode = "Tapping 'done' will stop the editing of cards and save any changes."
        static let notInEditMode = "Tapping 'manage cards' will allow you to edit the order of your cards, and remove any cards you no longer want in your list of passes."
        static let navHint = "Your Covid Vaccine Cards"
        static let proofOfVaccineCardAdded = "Your proof of vaccination has been added to your passes. Vaccination Card Expanded"
    }
    
    struct OpenWebLink {
        static let openWebLinkHint = "Open Website link for more intormation"
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
    
    struct VaccineCardView {
        static let vaccineCardExpanded = "Vaccination Card Expanded"
        static let vaccineCardCollapsed = "Vaccination Card Collapsed"
        static let qrCodeImage = "QR code image"
        static let inEditMode = "In edit mode: Swipe up or down for special actions, and you can unlink a card or adjust the order of your cards"
        static let expandedAction = "Action Available: Tap to zoom in QR code"
        static let collapsedAction = "Action Available: Tap to expand Vaccination Card"
    }
    
    struct FederalPassView {
        static let fedPassDescriptionHasPass = "This is your federal proof of vaccination link. Double tap to show your proof."
        static let fedPassDescriptionDoesNotHavePass = "This is your federal proof of vaccination link. Double tap to get your proof from Health Gateway."
        static let hasPassHint = "Double tapping this button will open your federal proof of vaccination PDF."
        static let noPassHint = "Double tapping this button will take you to health gateway where you can provide your personal health number to retrieve your federal proof of vaccination."
    }
    
    struct FormTextField {
        static let numberFormat = "Number Format"
        static let dateFormat = "Date Format"
        static let required = "Required"
    }
    
    struct ZoomedInQRImage {
        static let zoomedInQR = "Zoomed in QR code presented"
    }
    
    struct Settings {
        static let privacyStatementLink = "Privacy Statement Link"
        static let privacyStatementHint = "Action Available: Tapping the privacy statement link will take you to the privacy statement web page"
    }
    
    struct UnlinkFunctionality {
        static let unlinkButton = "Unlink Button"
    }
    
    struct Camera {
        static let notifyUserCameraOpened = "Camera has been opened to scan a QR code"
        static let closeText = "Close"
        static let closeHint = "Tapping the close button will dismiss the camera and return you to the previous screen"
    }
    
    struct GatewayForm {
        static let navHint = "the QR Retrieval Methods"
    }
}

