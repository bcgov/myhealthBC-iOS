//
//  StaticPositiveTestTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// FigmaLink: https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=3582%3A42731

import UIKit
// TODO: Need to fill in details of this cell, note that the data will be static, so we will only load this cell for a positive test result (logic to include cell in data source will be in view controller) - see figma for design reference
class StaticPositiveTestTableViewCell:  UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak private var headingLabel: UILabel!
    @IBOutlet weak var attributedTextView: UITextView!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    @IBOutlet weak private var attributedTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        headingLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        headingLabel.textColor = AppColours.textBlack
        attributedTextView.font = UIFont.bcSansRegularWithSize(size: 17)
        attributedTextView.textColor = AppColours.textBlack
        textSetup()
    }
    
    private func textSetup() {
        headingLabel.text = .instructions
        let attributedText = NSMutableAttributedString(string: .instructionsMessage)
        _ = attributedText.setAsLink(textToFind: "8-1-1", linkURL: "tel://811")
        _ = attributedText.setAsLink(textToFind: "Understanding Test Results", linkURL: "http://www.bccdc.ca/health-info/diseases-conditions/covid-19/testing/understanding-test-results")
        attributedTextView.attributedText = attributedText
        attributedTextView.isUserInteractionEnabled = true
        attributedTextView.delegate = self
        attributedTextView.font = UIFont.bcSansRegularWithSize(size: 17)
        attributedTextView.translatesAutoresizingMaskIntoConstraints = true
        attributedTextView.sizeToFit()
        attributedTextView.isScrollEnabled = false
        self.layoutIfNeeded()
    }
    
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
}


extension NSMutableAttributedString {
    public func range(textToFind: String) -> NSRange? {
        self.mutableString.range(of: textToFind)
    }
    
    public func setAsLink(textToFind:String, linkURL:String) -> NSRange? {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return foundRange
        }
        return nil
    }
}
