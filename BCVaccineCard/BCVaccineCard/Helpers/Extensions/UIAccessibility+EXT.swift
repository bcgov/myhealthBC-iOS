//
//  UIAccessibility+EXT.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-28.
// Use delay of 0.8 seconds if needed in an init method
import UIKit

extension UIAccessibility {
    static func setFocusTo(_ object: Any?) {
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                UIAccessibility.post(notification: .layoutChanged, argument: object)
            }
        }
    }
}
