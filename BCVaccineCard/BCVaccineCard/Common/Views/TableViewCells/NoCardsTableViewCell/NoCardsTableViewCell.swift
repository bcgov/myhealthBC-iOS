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
        introTextLabel.text = .noCardsIntroText
        introTextLabel.textColor = AppColours.textBlack
        introTextLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        
        noCardsLabel.text = .noCardsYet
        noCardsLabel.font = UIFont.bcSansBoldWithSize(size: 13)
        noCardsLabel.textColor = AppColours.appBlue
        
        introTextLabel.isAccessibilityElement = true
        introTextLabel.accessibilityTraits = .staticText
        introTextLabel.accessibilityValue = .noCardsIntroText
        
        noCardsImageView.isAccessibilityElement = true
        noCardsImageView.accessibilityTraits = .image
        noCardsImageView.accessibilityLabel = "Empty vaccine pass image"
        
        noCardsLabel.isAccessibilityElement = true
        noCardsLabel.accessibilityTraits = .staticText
        noCardsLabel.accessibilityValue = .noCardsYet
        
        addButton.isAccessibilityElement = true
        addButton.accessibilityTraits = .button
        addButton.accessibilityLabel = "Add Card"
        addButton.accessibilityHint = "Tapping this button will also bring you to a new screen with different options to retrieve your QR code"
        
    }
    
    func configure(withOwner vc: UIViewController, height: CGFloat) {
        addButton.configure(withStyle: .blue, buttonType: .addABCVaccineCard, delegateOwner: vc, enabled: true)
        stackViewViewHeight.constant = height
    }
    
}
