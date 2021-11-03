//
//  NoCardsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class NoCardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var introTextLabel: UILabel!
    @IBOutlet weak private var noCardsLabel: UILabel!
    @IBOutlet weak private var noCardsImageView: UIImageView!
    @IBOutlet weak private var addButton: AppStyleButton!
    @IBOutlet weak private var stackViewViewHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
//        introTextLabel.text = .noCardsIntroText
        introTextLabel.attributedText = attributedText(withString: .noCardsIntroText, boldStrings: [.bcVaccineCard, .federalProofOfVaccination], normalFont: UIFont.bcSansRegularWithSize(size: 17), boldFont: UIFont.bcSansBoldWithSize(size: 17), textColor: AppColours.textBlack)
//        introTextLabel.textColor = AppColours.textBlack
//        introTextLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        
        noCardsLabel.text = .noCardsYet
        noCardsLabel.font = UIFont.bcSansBoldWithSize(size: 13)
        noCardsLabel.textColor = AppColours.appBlue
        
        introTextLabel.isAccessibilityElement = true
        introTextLabel.accessibilityTraits = .staticText
        introTextLabel.accessibilityLabel = .noCardsIntroText
        
        noCardsImageView.isAccessibilityElement = false
        
        noCardsLabel.isAccessibilityElement = true
        noCardsLabel.accessibilityTraits = .staticText
        noCardsLabel.accessibilityLabel = .noCardsYet
        
        addButton.isAccessibilityElement = true
        addButton.accessibilityTraits = .button
        addButton.accessibilityLabel = AccessibilityLabels.NoCards.addCardLabel
        addButton.accessibilityHint = AccessibilityLabels.NoCards.addCardHint
        
        self.accessibilityElements = [introTextLabel, noCardsLabel, addButton]
        
    }
    
    func attributedText(withString string: String, boldStrings: [String], normalFont: UIFont, boldFont: UIFont, textColor: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: normalFont, NSAttributedString.Key.foregroundColor: textColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: boldFont]
        for boldString in boldStrings {
            let range = (string as NSString).range(of: boldString)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }
        return attributedString
    }
    
    func configure(withOwner vc: UIViewController, height: CGFloat) {
        addButton.configure(withStyle: .blue, buttonType: .addAHealthPass, delegateOwner: vc, enabled: true)
        stackViewViewHeight.constant = height
    }
    
}
