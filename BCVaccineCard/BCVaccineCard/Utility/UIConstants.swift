//
//  UIConstants.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-20.
//

import Foundation
import UIKit

extension Constants {
    
//    struct Strings {
//        static let vaccinationStatusHeader = "BC Vaccine Card Verifier"
//        static let scanAgain = "Scan Next"
//
//        struct shouldUpdate {
//            static let title = "Please Update"
//            static let message = "A new version of this app is available on the app store"
//        }
//
//        struct Errors {
//            struct CameraAccessIsNecessary {
//                static let title = "No Camera Access"
//                static let message = "Camera access is necessary to use this app."
//            }
//            struct MultipleQRCodes {
//                static let message = "There are multiple QR codes in view"
//            }
//            struct InvalidCode {
//                static let message = "Invalid QR Code"
//            }
//            struct VideoNotSupported {
//                static let title = "Unsupported Device"
//                static let message = "Please use a device that supports video capture."
//            }
//            struct QRScanningNotSupported {
//                static let title = "Unsupported Device"
//                static let message = "Your device does not support QR code scanning."
//            }
//        }
//    }
    
    struct UI {
        struct Theme {
            static let primaryColor = UIColor(hexString: "#003366")
            static let secondaryColor = UIColor(hexString: "#eea73b")
            static let primaryConstractColor = UIColor.white
            static let cornerRadius: CGFloat = 4
            static let animationDuration = 0.3
        }
        
        struct TorchButton {
            static let tag = 92133
            static let buttonSize: CGFloat = 42
        }
        
        struct QRCodeHighlighter {
            static let tag = 72192376
            static let cornerRadius: CGFloat = Constants.UI.Theme.cornerRadius
            static let borderWidth: CGFloat = 6
            static let borderColor = Constants.UI.Theme.secondaryColor.cgColor
            static let borderColorInvalid = UIColor.red.cgColor
        }
        
        struct LoadingIndicator {
            static let backdropTag = 45645676
            static let backdropColor = UIColor.black.withAlphaComponent(0.5)
            static let containerColor = UIColor.white
            static let containerSize: CGFloat = 70
            static let size: CGFloat = 30
        }
        
        struct Banner {
            static let tag = 232213
            static let displayDuration: Double = 2.0 // seconds
            static let backgroundColor = Constants.UI.Theme.primaryColor
            static let labelColor = Constants.UI.Theme.primaryConstractColor
            static let labelFont: UIFont = UIFont.init(name: "BCSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
            static let labelPadding: CGFloat = 8
            static let containerPadding: CGFloat = 16
        }
    }
}
