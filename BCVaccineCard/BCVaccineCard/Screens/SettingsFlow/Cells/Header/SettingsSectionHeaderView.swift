//
//  SettingsSectionHeaderView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-17.
//

import UIKit

class SettingsSectionHeaderView: UIView, Theme {
    
    @IBOutlet weak var titleLabel: UILabel!

    func setup(title: String) {
        self.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        titleLabel.text = title
        style(label: titleLabel, style: .Bold, size: 17, colour: .Blue)
    }
}
