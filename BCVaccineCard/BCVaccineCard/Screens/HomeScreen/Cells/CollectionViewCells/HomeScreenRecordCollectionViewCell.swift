//
//  HomeScreenCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-11.
//

import UIKit
// TODO: Update this for remote quick links possibility
// Add "QuickLink" type with an associated value (type, which is a "QuickLinkName" type, part of the ManageHomeScreenViewController
enum HomeScreenCellType {
    case Records
    case ImmunizationSchedule
    case Recommendations
    case Resources
    case Proofs
    case QuickLink(type: ManageHomeScreenViewController.QuickLinksNames)
    
    var getTitle: String {
        switch self {
        case .Records: return "Health\nRecords"
        case .Proofs: return "Proof of\nVaccination"
        case .Resources: return "Health\nResources"
        case .ImmunizationSchedule: return "Immunization\nSchedules"
        case .Recommendations: return "Recommended\nImmunizations"
        case .QuickLink(type: let type):
            return type.getHomeScreenDisplayableName
        }
    }
    
    var getIcon: UIImage? {
        switch self {
        case .Records: return UIImage(named: "records-home-icon")
        case .Proofs: return UIImage(named: "proofs-home-icon")
        case .Resources: return UIImage(named: "resources-home-icon")
        case .ImmunizationSchedule: return UIImage(named: "immunization-schedules-icon")
        case .Recommendations: return UIImage(named: "recommended-immunizations-icon")
        case .QuickLink(type: let type):
            if let name = type.getHomeScreenIconStringName, let image = UIImage(named: name) {
                return image
            } else {
                return nil
            }
        }
    }
    // May become irrelevant
    var getDescriptionText: String {
        switch self {
        case .Records: return "Access your lab test results, medication history, immunization records, health visits and more"
        case .Proofs: return "Save proof of vaccination documents for you and your family"
        case .Resources: return "Find trusted health information and resources"
        case .Recommendations: return "Find out which vaccinations are recommended for you"
        case .ImmunizationSchedule:
            return "Find out which vaccinations are recommended for you"
        case .QuickLink(type: let type):
            return ""
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
        case .ImmunizationSchedule: return UIImage(named: "resources-home-button")
        case .QuickLink(type: let type):
            return nil
        }
    }
    
    var hasRightCornerButton: Bool {
        switch self {
        case .QuickLink(type: let type): return true
        default: return false
        }
    }

}

protocol HomeScreenRecordCollectionViewCellDelegate: AnyObject {
    func moreOptions(indexPath: IndexPath?)
}

class HomeScreenRecordCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
//    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var buttonImageView: UIImageView!
    @IBOutlet weak private var rightCornerButton: UIButton!
//    @IBOutlet weak private var titleHeight: NSLayoutConstraint!
    
    weak private var delegate: HomeScreenRecordCollectionViewCellDelegate?
    private var indexPath: IndexPath?

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
        
        titleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        titleLabel.textColor = AppColours.appBlue
//        descriptionLabel.font = UIFont.bcSansRegularWithSize(size: 13)
//        descriptionLabel.textColor = AppColours.textBlack
    }
    
    func configure(forType type: HomeScreenCellType, delegateOwner: UIViewController, indexPath: IndexPath) {
        self.indexPath = indexPath
        iconImageView.image = type.getIcon
        titleLabel.text = type.getTitle
        rightCornerButton.isHidden = !type.hasRightCornerButton
        self.delegate = delegateOwner as? HomeScreenRecordCollectionViewCellDelegate
//        descriptionLabel.text = type.getDescriptionText
//        buttonImageView.image = type.getButtonImage(auth: auth)
//        titleHeight.constant = type.getTitle.heightForView(font: UIFont.bcSansBoldWithSize(size: 17), width: titleLabel.bounds.width)
    }
    
    @IBAction private func rightCornerButtonTapped(_ sender: UIButton) {
        delegate?.moreOptions(indexPath: self.indexPath)
    }

}
