//
//  DependentDelegateCountTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-16.
//

import UIKit

class DependentDelegateCountTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        headerLabel.font = UIFont.bcSansRegularWithSize(size: 14)
        headerLabel.textColor = AppColours.textBlack
        headerLabel.text = "How many others have access"
        valueLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        valueLabel.textColor = AppColours.textBlack
        detailsLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        detailsLabel.textColor = AppColours.textGray
        detailsLabel.text = "This shows you how many people other than you have added your dependent to their Health Gateway account. For privacy, we can’t tell you their names. If this number isn’t what you expect, contact us at healthgateway@gov.bc.ca"
    }
    
    func configure(delegateCount: Int) {
        valueLabel.text = "\(delegateCount)"
    }
    
}
