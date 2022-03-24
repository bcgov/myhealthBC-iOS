//
//  AppColours.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit
// TODO: Update color values
class AppColours {
    
    static let appBlue = UIColor(red: 0/255, green: 51/255, blue: 102/255, alpha: 1.0)
    static let appBlueLight = UIColor(red: 0.851, green: 0.918, blue: 0.969, alpha: 1)
    static let vaccinatedGreen = UIColor(red: 72/255, green: 131/255, blue: 72/255, alpha: 1.0)
    static let partiallyVaxedBlue = UIColor(red: 45/255, green: 89/255, blue: 145/255, alpha: 1.0)
    static let backgroundGray = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    static let appRed = UIColor.red
    static let barYellow = UIColor(red: 252/255, green: 186/255, blue: 25/255, alpha: 1.0)
    static let textBlack = UIColor(red: 49/255, green: 49/255, blue: 50/255, alpha: 1.0)
    static let textGray = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1.0)
    static let lightGray = UIColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1.0)
    static let borderGray = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    static let commentBackground = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    static let commentDateTime = UIColor(red: 0.376, green: 0.376, blue: 0.376, alpha: 1)
    static let divider = UIColor(red: 0.22, green: 0.349, blue: 0.541, alpha: 0.3)
    static let lightBlueText = UIColor(red: 0.102, green: 0.353, blue: 0.588, alpha: 1)
    
    struct CovidTest {
        static let pendingText = appBlue
        static let pendingBackground = appBlueLight
        
        static let cancelledText = pendingText
        static let cancelledBackground = pendingBackground
        
        static let negativeText = UIColor(hexString: "#2E8540")
        static let negativeBackground = UIColor(hexString: "#DFF0D8")
        
        static let positiveText = UIColor(hexString: "#A12622")
        static let positiveBackground = UIColor(hexString: "#F2DEDE")
        
        static let indeterminateText = pendingText
        static let indeterminateBackground = pendingBackground
        
        
    }
}
