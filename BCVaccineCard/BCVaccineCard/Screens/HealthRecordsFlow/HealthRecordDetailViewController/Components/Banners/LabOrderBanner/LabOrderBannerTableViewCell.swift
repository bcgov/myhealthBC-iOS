//
//  LabOrderBsnnerTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-06-30.
//

import UIKit

class LabOrderBannerTableViewCell: UITableViewCell, UITextViewDelegate {
    
    enum LabOrderBsnnerType {
        case Pending
        case NoTests
        case Cancelled
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    private let textColor = UIColor(red: 0.102, green: 0.353, blue: 0.588, alpha: 1)
    private let bgColor = UIColor(red: 0.851, green: 0.918, blue: 0.969, alpha: 1)
    
    func setup(type: LabOrderBsnnerType) {
        layoutIfNeeded()
        let fontAttribute = [NSAttributedString.Key.font: UIFont.bcSansRegularWithSize(size: 15), NSAttributedString.Key.foregroundColor: textColor]
        let body: NSMutableAttributedString
        
        switch type {
        case .Pending:
            titleLabel.text = "Results are pending"
            body = NSMutableAttributedString(string: "It can take between 1 and 7 days to complete.", attributes: fontAttribute)
        case .NoTests:
            titleLabel.text = "Results are pending"
            body = NSMutableAttributedString(string: "It can take between 1 and 7 days to complete. Find resources to learn about your lab test and what the results mean. Learn more", attributes: fontAttribute)
            _ = body.setAsLink(textToFind: "Learn more", linkURL: "https://www.healthgateway.gov.bc.ca/faq")
        case .Cancelled:
            titleLabel.text = "Your test has been cancelled"
            body = NSMutableAttributedString(string: "Find resources to learn about your lab test and what the results mean", attributes: fontAttribute)
            _ = body.setAsLink(textToFind: "your lab test and what the results mean", linkURL: "https://www.healthgateway.gov.bc.ca/faq")
            textView.isUserInteractionEnabled = true
            textView.isSelectable = true
            
        }
        textView.attributedText = body
        textView.delegate = self
        style()
        layoutIfNeeded()
        textView.sizeToFit()
        layoutIfNeeded()
    }
    
    private func style() {
        backgroundColor = bgColor
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        textView.textColor = textColor
        titleLabel.textColor = textColor
        textView.backgroundColor = .clear
        let padding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset =  UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        layer.cornerRadius = 4
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
