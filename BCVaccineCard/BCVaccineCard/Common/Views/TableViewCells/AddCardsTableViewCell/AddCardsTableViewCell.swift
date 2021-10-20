//
//  AddCardsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-14.
//

import UIKit

protocol AddCardsTableViewCellDelegate: AnyObject {
    func addCardButtonTapped()
}

class AddCardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var boldTextLabel: UILabel!
    @IBOutlet weak var subtextLabel: UILabel!
    @IBOutlet weak var addCardButton: UIButton!
    
    weak private var delegate: AddCardsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        labelSetup()
    }
    
    private func labelSetup() {
        boldTextLabel.font = UIFont.boldSystemFont(ofSize: 17)
        boldTextLabel.text = .bcVaccineCards
        boldTextLabel.textColor = .black
        subtextLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        subtextLabel.textColor = AppColours.textGray
        if #available(iOS 15.0, *) {
            addCardButton.configuration?.title = nil
        } else {
            addCardButton.setTitle(nil, for: .normal)
        }
        addCardButton.accessibilityLabel = "Add Card Button"
        addCardButton.accessibilityHint = "Tap this button to add a vaccine card"
    }
    
    @IBAction func addCardButtonTapped(_ sender: UIButton) {
        delegate?.addCardButtonTapped()
    }
    
    func configure(savedCards: Int?, delegateOwner: UIViewController) {
        if let savedCards = savedCards, savedCards > 1 {
            subtextLabel.isHidden = false
            subtextLabel.text = .passCount(count: "\(savedCards)")
        } else {
            subtextLabel.isHidden = true
        }
        self.delegate = delegateOwner as? AddCardsTableViewCellDelegate
    }

}
