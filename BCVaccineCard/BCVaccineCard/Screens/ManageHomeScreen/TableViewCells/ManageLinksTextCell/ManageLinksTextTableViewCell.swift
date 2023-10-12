//
//  ManageLinksTextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-08-01.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class ManageLinksTextTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var manageTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        manageTextLabel.textColor = AppColours.appBlue
        manageTextLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        manageTextLabel.text = "Set a folder to display on your home page for quick and easy access."
    }
}
