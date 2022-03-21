//
//  HomeScreenTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-16.
//
// Constraints: 30 from sides, 8 on top and bottom

import UIKit

enum HomeScreenCellType {
    case Records
    case Proofs
    case Resources
    
    var getTitle: String {
        switch self {
        case .Records: return "Health Records"
        case .Proofs: return "Proof of Vaccination"
        case .Resources: return "Resources"
        }
    }
    
    var getIcon: UIImage? {
        switch self {
        case .Records: return UIImage(named: "records-home-icon")
        case .Proofs: return UIImage(named: "proofs-home-icon")
        case .Resources: return UIImage(named: "resources-home-icon")
        }
    }
    
    var getDescriptionText: String {
        switch self {
        case .Records: return "View and manage all your available health records, including dispensed medications, health visits, COVID-19 test results, immunizations and more."
        case .Proofs: return "View, download and print your BC Vaccine Card and federal proof of vaccination, to access events, businesses, services and to travel."
        case .Resources: return "Find useful information and learn how to get vaccinated or tested for COVID-19."
        }
    }
    
    func getButtonImage(auth: Bool) -> UIImage? {
        switch self {
        case .Records:
            let image = auth ? UIImage(named: "records-home-button-auth") : UIImage(named: "records-home-button-unauth")
            return image
        case .Proofs: return UIImage(named: "proofs-home-button")
        case .Resources: return UIImage(named: "resources-home-button")
        }
    }
    
    var getTabIndex: Int {
        switch self {
        case .Records: return TabBarVCs.records.rawValue
        case .Proofs: return TabBarVCs.healthPass.rawValue
        case .Resources: return TabBarVCs.resource.rawValue
        }
    }

}

class HomeScreenTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var buttonImageView: UIImageView!

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
    }
    
}
