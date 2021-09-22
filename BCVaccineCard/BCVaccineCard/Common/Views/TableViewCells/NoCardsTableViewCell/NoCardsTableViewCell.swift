//
//  NoCardsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class NoCardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var noCardsLabel: UILabel!
    @IBOutlet weak private var addButton: AppStyleButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        noCardsLabel.text = Constants.Strings.MyCardFlow.NoCards.description
        noCardsLabel.font = UIFont.bcSansRegularWithSize(size: 14)
        noCardsLabel.textColor = AppColours.textBlack
    }
    
    func configure(withOwner vc: UIViewController) {
        addButton.configure(withStyle: .blue, buttonType: .addCard, delegateOwner: vc, enabled: true)
    }
    
}
