//
//  OnboardingiPadCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-11-06.
//

import UIKit

class OnboardingiPadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var resourceImageView: UIImageView!
    @IBOutlet weak private var newTextLabel: UILabel!
    @IBOutlet weak private var onboardingTitleLabel: UILabel!
    @IBOutlet weak private var onboardingDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // NOTE: Currently in stack view, may have to remove from stack view if I need to adjust the position of the image
    
    private func setup() {
        newTextLabel.font = UIFont.bcSansBoldWithSize(size: 13)
        newTextLabel.textColor = AppColours.appBlue
        newTextLabel.text = .new
        onboardingTitleLabel.font = UIFont.bcSansBoldWithSize(size: 33)
        onboardingTitleLabel.textColor = AppColours.appBlue
        onboardingDescriptionLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        onboardingDescriptionLabel.textColor = AppColours.textBlack
    }
    
    func configure(screenType: OnboardingScreenType, newTextShown: Bool) {
        resourceImageView.image = screenType.getIpadResourceImage
//        let sizes = screenType.getResourceImageSizes
//        resourceImageViewWidthConstraint.constant = sizes.width
//        resourceImageViewHeightConstraint.constant = sizes.height
//        resourceImageViewCenterXConstraint.constant = sizes.xOffset
//        resourceImageViewCenterYConstraint.constant = sizes.yOffset
        newTextLabel.isHidden = !newTextShown
        onboardingTitleLabel.text = screenType.getTitle
        onboardingDescriptionLabel.text = screenType.getDescription
        self.layoutIfNeeded()
    }

}
