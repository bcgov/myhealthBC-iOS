//
//  Constants.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import Foundation
import UIKit

struct Constants {
    struct Strings {
//        static let vaccinationStatusHeader = "BC Vaccine Card Verifier"
//        static let scanAgain = "Scan Next"
        
        struct Errors {
            struct CameraAccessIsNecessary {
                static let title = "No Camera Access"
                static let message = "Camera access is necessary to use this app."
            }
            struct MultipleQRCodes {
                static let message = "There are multiple QR codes in view"
            }
            struct InvalidCode {
                static let message = "Invalid QR Code"
            }
            struct VideoNotSupported {
                static let title = "Unsupported Device"
                static let message = "Please use a device that supports video capture."
            }
            struct QRScanningNotSupported {
                static let title = "Unsupported Device"
                static let message = "Your device does not support QR code scanning."
            }
        }
        
        struct TabBar {
            static let myCards = "My Cards"
            static let settings = "Settings"
        }
        
        struct ButtonTitles {
            static let cancel = "Cancel"
            static let enter = "Enter"
            static let done = "Done"
            static let saveACopy = "Save A Copy"
            static let close = "Close"
            static let manageCards = "Manage Cards"
            static let addCard = "+ Add Card"
        }
        
        struct MyCardFlow {
            static let navHeader = "My Cards"
            
            struct NoCards {
                static let buttonTitle = "Add Card"
                static let description = "You don't have any vaccine card yet"
            }
            
            struct HasCards {
                static let manageCardsButtonTitle = "Manage Cards"
                static let doneButtonTitle = "Done"
                static let fullyVaccinated = "VACCINATED"
                static let partiallyVaccinated = "PARTIALLY VACCINATED"
                static let noRecordFound = "NO RECORD FOUND"
                static let issuedOn = "Issued on "
                static let tapToZoomIn = "Tap to zoom in"
                static let presentForScanning = "PresentForScanning"
            }
            
            struct QRMethodSelection {
                static let description = "Scan, upload or get access to your proof of vaccination."
                static let cameraScanOption = "Scan a vaccine card QR code"
                static let imageUploadOption = "Use an image of your QR code"
                static let healthGatewayOption = "Enter info to get your card"
            }
            
            struct Form {
                static let title = "Add BC Vaccine Card"
                static let description = "To access your BC Vaccine Card, please provide:"
                static let personalHealthNumber = "Personal Health Number"
                static let dateOfBirth = "Date of birth"
                static let dateOfVaccine = "Date of vaccination (Dose 1 or Dose 2"
                static let privacyStatement = "Privacy Statement"
                static let cancelButtonTitle = "Cancel"
                static let enterButtonTitle = "Enter"
                static let nextText = "Next"
                
            }
        }
        
        struct Settings {
            static let navHeader = "Settings"
            static let openingText = "BC Vaccine Card app is the official mobile application from the Government of British Columbia which allow you to store and organze the proof of vaccination of you and your family members."
            static let privacyStatement = "Privacy Statement"
            static let help = "Help"
            
        }
        
    }
}
