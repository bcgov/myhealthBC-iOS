//
//  AccessibilityLabels.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-27.
//
// FIXME: NEED TO LOCALIZE - LOW PRIORITY
import Foundation

struct AccessibilityLabels {
    
    struct MyHealthPassesScreen {
        static let navRightIconTitle = String.settings
        static let navRightIconHint = String.tappingButtonBringToSettings
    }
    
    struct HealthGatewayScreen {
        static let navLeftIconTitle = String.close
        static let navLeftIconHint = String.tappingButtonTeturnToPreviousScreen
        static let navRightIconTitle = String.help
        static let navRightIconHint = String.tappingButtonBringHelpScreen
    }
    
    struct CovidVaccineCardsScreen {
        static let navRightDoneIconTitle = String.done
        static let navRightDoneIconHint = String.tappingWillFinishEditing
        static let navRightEditIconTitle = String.edit
        static let navRightEditIconHint = String.tappingWillAllowYouEditYourListOfCards
        static let navRightIconTitle = String.addCard
        static let navRightIconHint = String.tappingWillBringNewScreenWithOptionsRetrieveQR
        static let inEditMode = String.tappingDoneStopEditing
        static let notInEditMode = String.tappingManageCardsWillAllowEditTheOrderOfCards
        static let navHint = String.yourCovidVaccineCards
        static let proofOfVaccineCardAdded = "\(String.yourProofOfVaccinationAddedToYourPasses) \(String.vaccinationCardExpanded)"
    }
    
    struct ListOfHealthRecordsScreen {
        static let navRightDoneIconTitle = String.done
        static let navRightDoneIconHint = String.tappingWillFinishEditing
        static let navRightEditIconTitle = String.edit
        static let navRightEditIconHint = String.tappingButtonAllowYouEditRecords
        static let inEditMode = String.tappingDoneWillStopEditingRecords
        static let navHint = String.yourHealthRecords
    }
    
    struct HealthRecords {
        static let cardHint = String.doubleTapNavigateToUsersRecords
    }
    
    struct UserRecord {
        static let cardHint = String.tapToNavigateToRecordDetails
    }
    
    struct HealthRecordsDetailScreen {
        static let navRightIconTitle = String.delete
        static let navRightIconHint = String.tappingWillDeleteThisRecord
        static let navHint = String.yourHealthRecord
        
        static let navRightIconTitlePDF = "PDF View"
        static let navRightIconHintPDF = "Double tapping will open a PDF view of your detailed health record"
    }
    
    struct OpenWebLink {
        static let openWebLinkHint = String.openWebsiteLinkForMoreInformation
    }
    
    struct Navigation {
        static let backButtonTitle = String.back
        static let backButtonHint = String.tappingWillTakeYouBackTo
    }
    
    struct Onboarding {
        static let buttonNextTitle = String.next
        static let buttonNextHint = String.tappingWillTakeToIntroductionOfNextFeature
        static let buttonGetStartedTitle = String.getStarted
        static let buttonGetStartedHint = String.tappingWillTakeYouToHealthPassesHome
        static let buttonOkTitle = String.okay
        static let buttonOkHint = String.tappingWillTakeYouToHealthPassesHome
    }
    
    struct QRMethods {
        static let scanWithCamera = String.tappingWillOpenYourCameraToScanQRcode
        static let uploadImage = String.tappingWillOpenYourCameraRollToSelectSavedQRCode
        static let enterGatewayInfo = String.tappingButtonWillTakeYouWhereYouEnterPrsonalHealthInfo
    }
    
    struct NoCards {
        static let addCardLabel = String.addCard
        static let addCardHint = String.tappingWillBringNewScreenWithOptionsRetrieveQR
    }
    
    struct AddCard {
        static let addCardLabel = String.addCard
        static let addCardHint = String.tapToAddVaccineCard
    }
    
    struct ViewAllButton {
        static let viewAllLabel = String.viewAll
        static let viewAllHint = String.tappingWillShowAllSavedCovid19VaccineCards
    }
    
    struct VaccineCardView {
        static let vaccineCardExpanded = String.vaccinationCardExpanded
        static let vaccineCardCollapsed = String.vaccinationCardCollapsed
        static let qrCodeImage = String.qrCodeImage
        static let inEditMode = String.inEditModeSwipeUpOrDownForSpecialActions
        static let expandedAction = String.actionAvailableTapToZoomIn
        static let collapsedAction = String.actionAvailableTapToExpandVaccinationCard
    }
    
    struct FederalPassView {
        static let fedPassDescriptionHasPass = String.federalProofOfVaccinationLink
        static let fedPassDescriptionDoesNotHavePass = String.federalProofOfVaccinationLinkToHealthGateway
        static let hasPassHint = String.doubleTappingWillOpenFederalProofPDF
        static let noPassHint = String.doubleTappingWillTakeYouToHealthGatewayForPersonalHealthNumber
    }
    
    struct FormTextField {
        static let numberFormat = String.numberFormat
        static let dateFormat = String.dateFormat
        static let required = String.required
    }
    
    struct ZoomedInQRImage {
        static let zoomedInQR = String.zoomedInQRCodePresented
    }
    
    struct Settings {
        static let privacyStatementLink = String.privacyStatementLink
        static let privacyStatementHint = String.actionAvailableTappingPrivacyLinkToWebPage
    }
    
    struct UnlinkFunctionality {
        static let unlinkCard = String.unlinkCardTitle
    }
    
    struct Camera {
        static let notifyUserCameraOpened = String.cameraOpenedToScanQR
        static let closeText = String.close
        static let closeHint = String.tappingCloseWillDismissCamera
    }
    
    struct GatewayForm {
        static let navHint = String.theQRRetrievalMethods
    }
    
    struct ProtectiveWordScreen {
        static let navLeftIconTitle = String.close
        static let navLeftIconHint = String.tappingButtonTeturnToPreviousScreen
    }
}

