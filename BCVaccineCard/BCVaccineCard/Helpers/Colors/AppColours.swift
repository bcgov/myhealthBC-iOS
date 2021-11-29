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
    static let vaccinatedGreen = UIColor(red: 72/255, green: 131/255, blue: 72/255, alpha: 1.0)
    static let partiallyVaxedBlue = UIColor(red: 45/255, green: 89/255, blue: 145/255, alpha: 1.0)
    static let backgroundGray = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    static let appRed = UIColor.red
    static let barYellow = UIColor(red: 252/255, green: 186/255, blue: 25/255, alpha: 1.0)
    static let textBlack = UIColor(red: 49/255, green: 49/255, blue: 50/255, alpha: 1.0)
    static let textGray = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1.0)
    static let lightGray = UIColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1.0)
    static let borderGray = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    
    struct CovidTest {
        static let pendingText = UIColor(hexString: "#1A5A96")
        static let pendingBackground = UIColor(hexString: "#D9EAF7")
        
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
