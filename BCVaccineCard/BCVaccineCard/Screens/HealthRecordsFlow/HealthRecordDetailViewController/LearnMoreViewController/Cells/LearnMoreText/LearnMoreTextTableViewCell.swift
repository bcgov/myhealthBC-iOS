//
//  LearnMoreTextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-03-06.
//

import UIKit

class LearnMoreTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var attrTextLabel: UILabel!
    @IBOutlet weak private var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        let string = "Follow the instructions from your health care provider. When needed, they can explain what your results mean. Remember:\n\n  \u{2022} Ranges are different between laboratories\n  \u{2022} Out of range results may be normal for you"
        attrTextLabel.attributedText = attributedText(withString: string, boldStrings: ["Ranges", "Out of range"], normalFont: UIFont.bcSansRegularWithSize(size: 17), boldFont: UIFont.bcSansBoldWithSize(size: 17))
        separatorView.backgroundColor = AppColours.backgroundGray
    }
    
    private func attributedText(withString string: String, boldStrings: [String], normalFont: UIFont, boldFont: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: normalFont, NSAttributedString.Key.foregroundColor: AppColours.textBlack])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: boldFont]
        for bString in boldStrings {
            let range = (string as NSString).range(of: bString)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }
        
        return attributedString
    }
    
}
