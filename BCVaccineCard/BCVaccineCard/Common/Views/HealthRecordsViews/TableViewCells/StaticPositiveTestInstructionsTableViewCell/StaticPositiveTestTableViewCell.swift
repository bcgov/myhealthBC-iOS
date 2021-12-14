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
        headingLabel.text = .instructions
        let attributedText = NSMutableAttributedString(string: .instructionsMessage)
        _ = attributedText.setAsLink(textToFind: "8-1-1", linkURL: "tel://811")
        _ = attributedText.setAsLink(textToFind: "understanding test result", linkURL: "http://www.bccdc.ca/health-info/diseases-conditions/covid-19/testing/understanding-test-results")
        attributedTextLabel.attributedText = attributedText
    }
    
}


extension NSMutableAttributedString {

    public func setAsLink(textToFind:String, linkURL:String) -> Bool {

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
