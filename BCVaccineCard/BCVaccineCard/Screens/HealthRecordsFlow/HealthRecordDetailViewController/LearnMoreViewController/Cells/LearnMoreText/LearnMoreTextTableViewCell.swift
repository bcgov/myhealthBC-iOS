//
//  LearnMoreTextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-03-06.
//

import UIKit

class LearnMoreTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var introTextLabel: UILabel!
    @IBOutlet weak private var bullet1Label: UILabel!
    @IBOutlet weak private var bullet1TextLabel: UILabel!
    @IBOutlet weak private var bullet2Label: UILabel!
    @IBOutlet weak private var bullet2TextLabel: UILabel!
    @IBOutlet weak private var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        let string = "Follow the instructions from your health care provider. When needed, they can explain what your results mean. Remember:\n\n  \u{2022} Ranges are different between laboratories\n  \u{2022} Out of range results may be normal for you"
        
        introTextLabel.attributedText = attributedText(withString: "Follow the instructions from your health care provider. When needed, they can explain what your results mean. Remember:", boldString: nil, normalFont: UIFont.bcSansRegularWithSize(size: 17), boldFont: nil)
        bullet1Label.attributedText = attributedText(withString: "  \u{2022}", boldString: nil, normalFont: UIFont.bcSansBoldWithSize(size: 17), boldFont: nil)
        bullet2Label.attributedText = attributedText(withString: "  \u{2022}", boldString: nil, normalFont: UIFont.bcSansBoldWithSize(size: 17), boldFont: nil)
        bullet1TextLabel.attributedText = attributedText(withString: "Ranges are different between laboratories", boldString: "Ranges", normalFont: UIFont.bcSansRegularWithSize(size: 17), boldFont: UIFont.bcSansBoldWithSize(size: 17))
        bullet2TextLabel.attributedText = attributedText(withString: "Out of range results may be normal for you", boldString: "Out of range", normalFont: UIFont.bcSansRegularWithSize(size: 17), boldFont: UIFont.bcSansBoldWithSize(size: 17))
        
        separatorView.backgroundColor = AppColours.borderGray
    }
    
    private func attributedText(withString string: String, boldString: String?, normalFont: UIFont, boldFont: UIFont?) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: normalFont, NSAttributedString.Key.foregroundColor: AppColours.textBlack])
        if let boldString = boldString, let boldFont = boldFont {
            let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: boldFont]
            let range = (string as NSString).range(of: boldString)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.2
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
}
