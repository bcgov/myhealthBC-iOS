//
//  ToggleSettingsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-11-08.
//

import UIKit

class ToggleSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var callback: ((Bool)->Void)?
    
    @IBAction func settingSwitchToggled(_ sender: Any) {
        if let callback = callback {
            callback(settingSwitch.isOn)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        titleLabel.textColor = .black
        titleLabel.font = UIFont.bcSansRegularWithSize(size: 18)
        subtitleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        settingSwitch.onTintColor = AppColours.appBlue
        settingSwitch.tintColor = AppColours.appBlue
    }
    
    func configure(title: String, subTitle: String, isOn: Bool, onToggle: @escaping(_ result: Bool) -> Void) {
        titleLabel.text = title
        subtitleLabel.text = subTitle
        settingSwitch.isOn = isOn
        callback = onToggle
    }
}
