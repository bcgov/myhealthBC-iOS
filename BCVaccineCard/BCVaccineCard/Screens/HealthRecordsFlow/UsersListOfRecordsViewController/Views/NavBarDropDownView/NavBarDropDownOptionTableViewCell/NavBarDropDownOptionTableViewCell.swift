//
//  NavBarDropDownOptionTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-04-21.
//

import UIKit

class NavBarDropDownOptionTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        titleLabel.textColor = AppColours.blueLightText
        iconImageView.tintColor = AppColours.blueLightText
        contentView.backgroundColor = AppColours.borderGray
        containerView.backgroundColor = .white
    }
    
    func configure(option: NavBarDropDownViewOptions, dataSourceCount: Int, positionInDropDown: Int) {
        titleLabel.text = option.getTitle
        iconImageView.image = option.getImage
        // Show top and bottom border unless first row, show no border, or bottom row, show only top border
        if positionInDropDown == 0 {
            topConstraint.constant = 0
            bottomConstraint.constant = 0
        } else if positionInDropDown == dataSourceCount - 1 {
            topConstraint.constant = 1
            bottomConstraint.constant = 0
        } else {
            topConstraint.constant = 1
            bottomConstraint.constant = 1
        }
        self.layoutIfNeeded()
        
    }
    
}
