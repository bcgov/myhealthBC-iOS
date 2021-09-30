//
//  UIConstants.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-09-20.
//

import Foundation
import UIKit

extension Constants {
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
        
        struct CameraView {
            struct CameraCutout {
                static let fillLayerName = "cutout-fill-layer"
                static let bornerLayerName = "border-layer"
                
                static let colour = UIColor(hexString: "313132").cgColor
                static let opacity: Float = 0.7
                static let cornerRadius: CGFloat = 10
                
                static var width: CGFloat {
                    switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                    case .pad:
                        return 506
                    default:
                        return 247
                    }
                }
                
                static var height: CGFloat {
                    switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
                    case .pad:
                        return 469
                    default:
                        return 293
                    }
                }
            }
            
            struct QRCodeHighlighter {
                static let tag = 72192376
                static let cornerRadius: CGFloat = Constants.UI.Theme.cornerRadius
                static let borderWidth: CGFloat = 6
                static let borderColor = Constants.UI.Theme.secondaryColor.cgColor
                static let borderColorInvalid = UIColor.red.cgColor
            }
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
        
        struct NavBarConstants {
            /// Image height/width for Large NavBar state
            static let ImageSizeForLargeState: CGFloat = 40
            /// Margin from right anchor of safe area to right anchor of Image
            static let ImageRightMargin: CGFloat = 16
            /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
            static let ImageBottomMarginForLargeState: CGFloat = 12
            /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
            static let ImageBottomMarginForSmallState: CGFloat = 6
            /// Image height/width for Small NavBar state
            static let ImageSizeForSmallState: CGFloat = 32
            /// Height of NavBar for Small state. Usually it's just 44
            static let NavBarHeightSmallState: CGFloat = 44
            /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
            static let NavBarHeightLargeState: CGFloat = 96.5
            /// Tag for the right bar button
            static let buttonTag: Int = 34863
        }
    }
}
