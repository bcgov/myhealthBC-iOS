//
//  OnboardingCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-04-04.
//

import UIKit
import SwiftUI

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    func getPhoneImage(for screen: OnboardingScreenType) -> UIImage? {
        switch screen {
        case .healthPasses:
            return UIImage(named: "phone-proofs")
        case .healthRecords:
            return UIImage(named: "phone-records")
        case .healthResources:
            return UIImage(named: "phone-resources")
        case .newsFeed:
            return UIImage(named: "bubble-news") // TODO: Delete
        }
    }
    // Note: Offset is width / 2
    func getPhoneImageSizes(for screen: OnboardingScreenType) -> (width: CGFloat, height: CGFloat, offset: CGFloat) {
        switch screen {
        case .healthRecords:
            return (width: 124, height: 139, offset: 0)
        case .healthPasses:
            return (width: 175, height: 161, offset: (175/2))
        case .healthResources:
            return (width: 175, height: 161, offset: (-175/2))
        case .newsFeed:
            return (width: 0, height: 0, offset: 0)
        }
    }
    
    func getTitle(for screen: OnboardingScreenType) -> String {
        switch screen {
        case .healthPasses:
            return .healthPasses.sentenceCase()
        case .healthRecords:
            return .healthRecords.sentenceCase()
        case .healthResources:
            return .healthResources.sentenceCase()
        case .newsFeed:
            return .newsFeed.sentenceCase()
        }
    }
    
    func getDescription(for screen: OnboardingScreenType) -> String {
        switch screen {
        case .healthPasses:
            return .initialOnboardingHealthPassesDescription
        case .healthRecords:
            return .initialOnboardingHealthRecordsDescription
        case .healthResources:
            return .initialOnboardingHealthResourcesDescription
        case .newsFeed:
            return .initialOnboardingNewsFeedDescription
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak private var phoneImageView: UIImageView!
    @IBOutlet weak private var phoneImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var phoneImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var phoneImageViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak private var newTextLabel: UILabel!
    @IBOutlet weak private var onboardingTitleLabel: UILabel!
    @IBOutlet weak private var onboardingDescriptionLabel: UILabel!

}
