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
        struct TabBar {
            static let viewControllersWithTabBar: [UIViewController.Type] = [HomeScreenViewController.self, HealthRecordsViewController.self, DependentsHomeViewController.self, ServicesViewController.self, UsersListOfRecordsViewController.self]
        }
        struct Theme {
            static let primaryColor = UIColor(hexString: "#003366")
            static let secondaryColor = UIColor(hexString: "#eea73b")
            static let primaryConstrastColor = UIColor.white
            static let animationDuration = 0.5
            static let cornerRadiusRegular: CGFloat = 5
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
                static let cornerRadius: CGFloat = Constants.UI.Theme.cornerRadiusRegular
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
        
        // MARK: Toast
        struct Toast {
            static let tag = 232213
            static let displayDuration: Double = 2.0 // seconds

            // Font
            static let labelFont: UIFont = UIFont.bcSansRegularWithSize(size: 14)
            // Padding
            static let labelPadding: CGFloat = 8
            static let containerPadding: CGFloat = 14
            static let bottomPadding: CGFloat = 64
            static let defaultHeight: CGFloat = 40
            
            // Colors
            static let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
            struct WarnColors {
                static let backgroundColor = UIColor(red: 0.976, green: 0.945, blue: 0.776, alpha: 1)
                static let labelColor = UIColor(red: 0.424, green: 0.29, blue: 0, alpha: 1)
            }
            struct defaultColors {
                static let backgroundColor = Constants.UI.Theme.primaryColor
                static let labelColor =  Constants.UI.Theme.primaryConstrastColor
            }
        }
        
        struct CellSpacing {
            struct QROptionsScreen {
                static let optionButtonHeight: CGFloat = 74
                static let staticText: CGFloat = 100
            }
        }
        
        struct RememberPHNDropDownRowHeight {
            static let height: CGFloat = 50
        }
    }
}
