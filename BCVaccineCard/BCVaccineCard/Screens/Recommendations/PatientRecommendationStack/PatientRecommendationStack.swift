//
//  PatientRecommendationStack.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-07-06.
//

import UIKit

class PatientRecommendationStack: UIView {

    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var immunizationNameLabel: UILabel!
    
    func configure(immunizationName: String?,
                   dueDate: Date?,
                   descrtiptionText: String? = nil,
                   eligibleDate: Date?,
                   icon: UIImage? = UIImage(named: "reccomandation-list-icon")) {
        immunizationNameLabel.text = immunizationName
        iconImageView.image = icon
        if let dueDate = dueDate {
            dueDateLabel.text = "Due: \(dueDate.forecastDueDate)"
        } else {
            dueDateLabel.isHidden = true
        }
        
        if let eligibleDate = eligibleDate {
            let textTag: TextTag = TextTag.fromNib()
            contentStack.insertArrangedSubview(textTag, at: 0)
            textTag.configure(text: "Eligible: \(eligibleDate.forecastDueDate)")
        }
        
        descriptionLabel.text = descrtiptionText
        if descrtiptionText == nil {
            descriptionLabel.isHidden = true
        }
        
        style()
    }
    
    func style() {
        dueDateLabel.textColor = AppColours.greyText
        immunizationNameLabel.textColor = AppColours.appBlue
        descriptionLabel.textColor = AppColours.greyText
        
        immunizationNameLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        dueDateLabel.font = UIFont.bcSansRegularWithSize(size: 10)
        descriptionLabel.font = UIFont.bcSansRegularWithSize(size: 10)
        backgroundColor = .clear
        
    }
}
