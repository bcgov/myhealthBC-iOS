//
//  MessageBannerTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-06-30.
//

import UIKit

class MessageBannerTableViewCell: BaseHeaderTableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    func setup(text: NSMutableAttributedString, bgColor: UIColor, messageColor: UIColor) {
        let padding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset =  UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        layoutIfNeeded()
        layer.cornerRadius = 4
        textView.attributedText = text
        textView.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
        textView.sizeToFit()
        backgroundColor = bgColor
        textView.textColor = messageColor
        textView.backgroundColor = .clear
        layoutIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
