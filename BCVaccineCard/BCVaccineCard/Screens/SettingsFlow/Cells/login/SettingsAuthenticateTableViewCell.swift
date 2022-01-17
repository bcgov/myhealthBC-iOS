//
//  SettingsAuthenticateTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-17.
//

import UIKit

class SettingsAuthenticateTableViewCell: UITableViewCell, Theme {
    // MARK: Variables
    fileprivate var callback: (()->Void)?

    // MARK: Outlets
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTapped(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(onTap: @escaping ()->Void) {
        self.callback = onTap
        style()
    }
    
    func style() {
        style(button: button, style: .Fill, title: "Log in with BC Services Card")
        if let icon = UIImage(named: "bcscLogo") {
            button.setImage(icon, for: .normal)
        }
       
    }
}
