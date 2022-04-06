//
//  OnboardingCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-04.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @IBOutlet weak private var phoneImageView: UIImageView!
    @IBOutlet weak private var resourceImageView: UIImageView!
    @IBOutlet weak private var resourceImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var resourceImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var resourceImageViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak private var resourceImageViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak private var newTextLabel: UILabel!
    @IBOutlet weak private var onboardingTitleLabel: UILabel!
    @IBOutlet weak private var onboardingDescriptionLabel: UILabel!
    
    private func setup() {
        newTextLabel.font = UIFont.bcSansBoldWithSize(size: 13)
        newTextLabel.textColor = AppColours.appBlue
        newTextLabel.text = .new
        onboardingTitleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        onboardingTitleLabel.textColor = AppColours.appBlue
        onboardingDescriptionLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        onboardingDescriptionLabel.textColor = AppColours.textBlack
    }
    
    func configure(screenType: OnboardingScreenType, newTextShown: Bool) {
        resourceImageView.image = screenType.getResourceImage
        let sizes = screenType.getResourceImageSizes
        resourceImageViewWidthConstraint.constant = sizes.width
        resourceImageViewHeightConstraint.constant = sizes.height
        resourceImageViewCenterXConstraint.constant = sizes.xOffset
        resourceImageViewCenterYConstraint.constant = sizes.yOffset
        newTextLabel.isHidden = !newTextShown
        onboardingTitleLabel.text = screenType.getTitle
        onboardingDescriptionLabel.text = screenType.getDescription
        self.layoutIfNeeded()
    }
}
