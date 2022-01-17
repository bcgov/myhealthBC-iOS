//
//  Theme.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//

import Foundation
import UIKit
protocol Theme {}

enum ButtonStyle {
    case Fill
    case Hollow
}

enum FontStyle {
    case Regular
    case Bold
}

enum LabelColour {
    case Grey
    case Blue
    case Black
    case Red
}

extension Theme {
    
    // Buttons
    public func style(button: UIButton, style: ButtonStyle, title: String, bold: Bool? = false) {
        switch style {
            
        case .Fill:
            styleButtonfill(button: button, bold: bold)
        case .Hollow:
            styleButtonHollow(button: button, bold: bold)
        }
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
    }
    
    // Labels
    public func style(label: UILabel, style: FontStyle, size: CGFloat, colour: LabelColour) {
        switch style {
        case .Regular:
            label.font = UIFont.bcSansRegularWithSize(size: size)
        case .Bold:
            label.font = UIFont.bcSansBoldWithSize(size: size)
        }
        
        switch colour {
        case .Grey:
            label.textColor = AppColours.textGray
        case .Blue:
            label.textColor = AppColours.appBlue
        case .Black:
            label.textColor = AppColours.textBlack
        case .Red:
            label.textColor = AppColours.appRed
        }
    }
    
    fileprivate func styleButtonHollow(button: UIButton, bold: Bool? = false) {
        button.backgroundColor = .white
        button.setTitleColor(AppColours.appBlue, for: .normal)
        button.borderColor = AppColours.appBlue
        button.borderWidth = 1
        if let label = button.titleLabel {
            if let bolded = bold, bolded {
                label.font = UIFont.bcSansBoldWithSize(size: 17)
            } else {
                label.font = UIFont.bcSansRegularWithSize(size: 17)
            }
            label.minimumScaleFactor = 0.6
        }
    }
    
    fileprivate func styleButtonfill(button: UIButton, bold: Bool? = false) {
        button.backgroundColor = AppColours.appBlue
        button.setTitleColor(.white, for: .normal)
        if let label = button.titleLabel {
            if let bolded = bold, bolded {
                label.font = UIFont.bcSansBoldWithSize(size: 17)
            } else {
                label.font = UIFont.bcSansRegularWithSize(size: 17)
            }
            
            label.minimumScaleFactor = 0.6
        }
    }
}
