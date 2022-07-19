//
//  SectionDescriptionTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-19.
//

import UIKit

class SectionDescriptionTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    func setup(title: String, subtitle: String) {
        layoutIfNeeded()
        style()
        titleLabel.text = title
        subtitleLabel.text = subtitle
        layoutIfNeeded()
    }
    
    func style() {
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        subtitleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        subtitleLabel.textColor = AppColours.greyText
        
    }
}
