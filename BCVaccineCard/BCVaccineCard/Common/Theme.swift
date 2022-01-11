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

extension Theme {
    
    // Buttons
    public func style(button: UIButton, style: ButtonStyle, title: String) {
        switch style {
            
        case .Fill:
            styleButtonfill(button: button)
        case .Hollow:
            styleButtonHollow(button: button)
        }
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
    }
    
    fileprivate func styleButtonHollow(button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(AppColours.appBlue, for: .normal)
        button.borderColor = AppColours.appBlue
        button.borderWidth = 1
        if let label = button.titleLabel {
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.minimumScaleFactor = 0.6
        }
    }
    
    fileprivate func styleButtonfill(button: UIButton) {
        button.backgroundColor = AppColours.appBlue
        button.setTitleColor(.white, for: .normal)
        if let label = button.titleLabel {
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            label.minimumScaleFactor = 0.6
        }
    }
}
