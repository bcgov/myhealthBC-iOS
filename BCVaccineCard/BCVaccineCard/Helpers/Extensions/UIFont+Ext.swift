//
//  UIFont+Ext.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

extension UIFont {
    
    static func bcSansBoldWithSize(size: CGFloat) -> UIFont {
        if let font = UIFont.init(name: "BCSans-Bold", size: size) {
            return font
        }
        return UIFont.boldSystemFont(ofSize: size)
    }
    
    static func bcSansBoldItalicWithSize(size: CGFloat) -> UIFont {
        if let font = UIFont.init(name: "BCSans-BoldItalic", size: size) {
            return font
        }
        return UIFont.boldSystemFont(ofSize: size)
    }
    
    static func bcSansItalicWithSize(size: CGFloat) -> UIFont {
        if let font = UIFont.init(name: "BCSans-Italic", size: size) {
            return font
        }
        return UIFont.italicSystemFont(ofSize: size)
    }
    
    static func bcSansRegularWithSize(size: CGFloat) -> UIFont {
        if let font = UIFont.init(name: "BCSans-Regular", size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
    
}
