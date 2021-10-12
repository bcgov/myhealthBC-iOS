//
//  String+Localizable.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-05.
//

import UIKit

extension String {
    
    /// The localized string for the key represented in `self`.
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
}

protocol XIBLocalizable {
    /// This key can be used in the interface builder to set the localized string
    var xibLocalizedKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    
    @IBInspectable var xibLocalizedKey: String? {
        get { return nil }
        set (key) { self.text = key?.localized }
    }
    
}

extension UIButton: XIBLocalizable {
    
    @IBInspectable var xibLocalizedKey: String? {
        get { return nil }
        set (key) { self.setTitle(key?.localized, for: .normal) }
    }
    
}

extension UITextField: XIBLocalizable {
    
    @IBInspectable var xibLocalizedKey: String? {
        get { return nil }
        set (key) { self.placeholder = key?.localized }
    }
    
}
