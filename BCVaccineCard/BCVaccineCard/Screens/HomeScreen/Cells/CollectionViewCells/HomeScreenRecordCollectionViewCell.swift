//
//  HomeScreenCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-11.
//

import UIKit

enum HomeScreenCellType {
    case Records
    case Recommendations(showRecommendedImz: Bool)
    case Resources
    case Proofs
    
    var getTitle: String {
        switch self {
        case .Records: return "Health records"
        case .Proofs: return "Proof of vaccination"
        case .Resources: return "Resources"
        case .Recommendations(let showRecommendedImz):
            let string = showRecommendedImz ? "Recommended\nimmunizations" : "Immunization\nschedules"
            return string
        }
    }
    
    var getIcon: UIImage? {
        switch self {
        case .Records: return UIImage(named: "records-home-icon")
        case .Proofs: return UIImage(named: "proofs-home-icon")
        case .Resources: return UIImage(named: "resources-home-icon")
        case .Recommendations(let showRecommendedImz):
            let icon = showRecommendedImz ? UIImage(named: "recommended-immunizations-icon") : UIImage(named: "immunization-schedules-icon")
            return icon
        }
    }
    // May become irrelevant
    var getDescriptionText: String {
        switch self {
        case .Records: return "Access your lab test results, medication history, immunization records, health visits and more"
        case .Proofs: return "Save proof of vaccination documents for you and your family"
        case .Resources: return "Find trusted health information and resources"
        case .Recommendations: return "Find out which vaccinations are recommended for you"
        }
    }
    // May become irrelevant
    func getButtonImage(auth: Bool) -> UIImage? {
        switch self {
        case .Records:
            let image = auth ? UIImage(named: "records-home-button-auth") : UIImage(named: "records-home-button-unauth")
            return image
        case .Proofs: return UIImage(named: "proofs-home-button")
        case .Resources: return UIImage(named: "resources-home-button")
        case .Recommendations:  return UIImage(named: "resources-home-button")
        }
    }

}

class HomeScreenRecordCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
//    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var buttonImageView: UIImageView!
//    @IBOutlet weak private var titleHeight: NSLayoutConstraint!

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
//        descriptionLabel.font = UIFont.bcSansRegularWithSize(size: 13)
//        descriptionLabel.textColor = AppColours.textBlack
    }
    
    func configure(forType type: HomeScreenCellType) {
        iconImageView.image = type.getIcon
        titleLabel.text = type.getTitle
//        descriptionLabel.text = type.getDescriptionText
//        buttonImageView.image = type.getButtonImage(auth: auth)
//        titleHeight.constant = type.getTitle.heightForView(font: UIFont.bcSansBoldWithSize(size: 17), width: titleLabel.bounds.width)
    }

}
