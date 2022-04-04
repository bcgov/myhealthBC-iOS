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
    
    // MARK: Class functions
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        style()
    }
    
    // MARK: Setup
    public func setup(onTap: @escaping ()->Void) {
        self.callback = onTap
        setup()
        style()
    }
    
    fileprivate func setup() {
        if let icon = UIImage(named: "profile-icon"), let imageView = iconImageView {
            imageView.image = icon
        }
        nameLabel.text = StorageService.shared.fetchAuthenticatedPatient()?.name?.nameCase() ?? AuthManager().displayName?.nameCase()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.contentView.gestureRecognizers?.removeAll()
        self.contentView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let callback = callback {
            callback()
        }
    }
    
    // MARK: Style
    fileprivate func style() {
        viewProfileLabel.text = .viewProfile
        style(label: viewProfileLabel, style: .Regular, size: 13, colour: .Grey)
        style(label: nameLabel, style: .Bold, size: 17, colour: .Blue)
    }
    
}
