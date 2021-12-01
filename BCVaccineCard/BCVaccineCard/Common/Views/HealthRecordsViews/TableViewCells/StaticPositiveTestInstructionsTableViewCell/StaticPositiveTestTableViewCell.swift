//
//  StaticPositiveTestTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// FigmaLink: https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=3582%3A42731

import UIKit
// TODO: Need to fill in details of this cell, note that the data will be static, so we will only load this cell for a positive test result (logic to include cell in data source will be in view controller) - see figma for design reference
class StaticPositiveTestTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var headingLabel: UILabel!
    @IBOutlet weak private var attributedTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        headingLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        headingLabel.textColor = AppColours.textBlack
        attributedTextLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        attributedTextLabel.textColor = AppColours.textBlack
        textSetup()
    }
    // TODO: Add to strings file
    // TODO: Add attributed text for description (for links)
    private func textSetup() {
        headingLabel.text = "Instructions"
        attributedTextLabel.text = "• You need to self-isolate now.\n• The people you live with will also need to self-isolate if they are not fully vaccinated.\n• Public health will contact you.\n• Monitor your health and contact a health care provider or call 8-1-1 if you are concerned about your symptoms.\n• Go to Understanding Test Results for more information"
    }
    
}
