//
//  SettingsProfileTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-17.
//

import UIKit

class SettingsProfileTableViewCell: UITableViewCell, Theme {
    // MARK: Variables
    fileprivate var callback: (()->Void)?
    
    // MARK: Outlets
    @IBOutlet weak var viewProfileLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fillData()
    }
    
    func setup(onTap: @escaping ()->Void) {
        self.callback = onTap
        style()
    }
    
    func fillData() {
        if let icon = UIImage(named: "profile-icon"), let imageView = iconImageView {
            imageView.image = icon
        }
        nameLabel.text = AuthManager().displayName
    }
    
    func style() {
        
    }
    
}
