//
//  NoCardsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class NoCardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var noCardsLabel: UILabel!
    @IBOutlet weak private var noCardsImageView: UIImageView!
    @IBOutlet weak private var addButton: AppStyleButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        noCardsLabel.text = Constants.Strings.MyCardFlow.NoCards.description
        noCardsLabel.font = UIFont.bcSansRegularWithSize(size: 14)
        noCardsLabel.textColor = AppColours.textBlack
        
        noCardsImageView.isAccessibilityElement = true
        noCardsImageView.accessibilityTraits = .image
        noCardsImageView.accessibilityLabel = "Empty vaccine wallet image"
        
        noCardsLabel.isAccessibilityElement = true
        noCardsLabel.accessibilityTraits = .staticText
        noCardsLabel.accessibilityValue = Constants.Strings.MyCardFlow.NoCards.description
        
        addButton.isAccessibilityElement = true
        addButton.accessibilityTraits = .button
        addButton.accessibilityLabel = "Add Card"
        addButton.accessibilityHint = "Tapping this button will also bring you to a new screen with different options to retrieve your QR code"
        
    }
    
    func configure(withOwner vc: UIViewController) {
        addButton.configure(withStyle: .white, buttonType: .addCard, delegateOwner: vc, enabled: true)
    }
    
}
