//
//  SettingsRowTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-17.
//

import UIKit

class SettingsRowTableViewCell: UITableViewCell, Theme {
    // MARK: Variables
    fileprivate var callback: (()->Void)?
    fileprivate var rowRitle: String?
    fileprivate var rowIcon: UIImage?

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageVIew: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: Setup
    func setup(title: String, icon: UIImage?, onTap: @escaping ()->Void) {
        self.callback = onTap
        rowRitle = title
        rowIcon = icon
        setup()
        style()
    }
    
    fileprivate func setup() {
        if let title = rowRitle {
            titleLabel.text = title
        }
        if let icon = rowIcon {
            iconImageVIew.image = icon
        }
    }
    
    // MARK: Style
    func style() {
        
    }
}
