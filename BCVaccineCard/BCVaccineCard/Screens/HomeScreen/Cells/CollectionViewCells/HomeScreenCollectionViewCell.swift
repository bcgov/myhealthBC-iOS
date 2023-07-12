//
//  HomeScreenCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-11.
//

import UIKit

class HomeScreenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var buttonImageView: UIImageView!
    @IBOutlet weak private var titleHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        viewSetup()
    }
    
    private func viewSetup() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowRadius = 6.0
        
        roundedView.layer.cornerRadius = 3
        roundedView.layer.masksToBounds = true
        
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        titleLabel.textColor = AppColours.textBlack
        descriptionLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        descriptionLabel.textColor = AppColours.textBlack
    }
    
    func configure(forType type: HomeScreenCellType, auth: Bool) {
        iconImageView.image = type.getIcon
        titleLabel.text = type.getTitle
        descriptionLabel.text = type.getDescriptionText
        buttonImageView.image = type.getButtonImage(auth: auth)
        titleHeight.constant = type.getTitle.heightForView(font: UIFont.bcSansBoldWithSize(size: 17), width: titleLabel.bounds.width)
    }

}
