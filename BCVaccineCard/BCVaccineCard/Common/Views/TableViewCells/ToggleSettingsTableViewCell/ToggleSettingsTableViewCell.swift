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
    private var onTitle: String = ""
    private var offTitle: String = ""
    
    @IBAction func settingSwitchToggled(_ sender: Any) {
        if let callback = callback {
            titleLabel.text = settingSwitch.isOn ? onTitle : offTitle
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
    
    func configure(onTitle: String, offTitle: String, subTitle: String, isOn: Bool, onToggle: @escaping(_ result: Bool) -> Void) {
        self.onTitle = onTitle
        self.offTitle = offTitle
        titleLabel.text = isOn ? onTitle : offTitle
        subtitleLabel.text = subTitle
        settingSwitch.isOn = isOn
        callback = onToggle
    }
}
