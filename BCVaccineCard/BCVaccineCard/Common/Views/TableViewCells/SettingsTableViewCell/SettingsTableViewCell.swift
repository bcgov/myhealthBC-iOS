//
//  SettingsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var settingIconImageView: UIImageView!
    @IBOutlet weak private var settingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        settingLabel.textColor = AppColours.appBlue
    }
    
    func configure(text: String, image: UIImage) {
        settingLabel.text = text
        settingIconImageView.image = image
    }
    
}
