//
//  HealthVisitRecordDetailTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-14.
//

import UIKit

class HealthVisitRecordDetailTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclaimer: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    func configure() {
        layoutIfNeeded()
        nameLabel.text = ""
        titleLabel.text = ""
        disclaimer.delegate = self
        
        titleLabel.font =  UIFont.bcSansBoldWithSize(size: 17)
        nameLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        let padding = disclaimer.textContainer.lineFragmentPadding
        disclaimer.textContainerInset =  UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        layoutIfNeeded()
        let disclaimerText = "Information is from the billing claim and may show a different practitioner or clinic from the one you visited. For more information, visit the FAQ page."
        let attributedText = NSMutableAttributedString(string: disclaimerText)
        _ = attributedText.setAsLink(textToFind: "FAQ", linkURL: "https://www2.gov.bc.ca/gov/content?id=FE8BA7F9F1F0416CB2D24CF71C4BAF80")
    
        disclaimer.attributedText = attributedText
        disclaimer.isUserInteractionEnabled = true
        disclaimer.delegate = self
        disclaimer.font = UIFont.bcSansRegularWithSize(size: 14)
        disclaimer.isScrollEnabled = false
        disclaimer.isEditable = false
        disclaimer.textColor = UIColor(red: 0.427, green: 0.459, blue: 0.49, alpha: 1)
        layoutIfNeeded()
    }
    
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        UIApplication.shared.open(URL)
        AppDelegate.sharedInstance?.showExternalURL(url: URL.absoluteString)
        return false
    }
    
}
