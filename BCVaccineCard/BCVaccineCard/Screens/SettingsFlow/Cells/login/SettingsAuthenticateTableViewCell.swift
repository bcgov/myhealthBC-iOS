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
    
    // MARK: Outlet Actions
    @IBAction func buttonTapped(_ sender: Any) {
        if let callback = callback {
            callback()
        }
    }
    
    // MARK: Class functions
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    // MARK: Setup
    public func setup(onTap: @escaping ()->Void) {
        self.callback = onTap
        style()
    }
    
    // MARK: Style
    fileprivate func style() {
        style(button: button, style: .Fill, title: .bcscLogin, bold: true)
        if let icon = UIImage(named: "bcscLogo") {
            button.setImage(icon, for: .normal)
        }
       
    }
}
