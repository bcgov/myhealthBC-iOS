//
//  PatientRecomandationsHeaderView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-07-06.
//

import UIKit

protocol PatientRecomandationsHeaderViewDelegate {
    func toggle(patient: Patient)
}

class PatientRecomandationsHeaderView: UIView {
    
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numerOfRecommendations: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var userLogoImageView: UIImageView!
    
    var patient: Patient? = nil
    var delegate: PatientRecomandationsHeaderViewDelegate? = nil
    
    func configure(patient: Patient, expanded: Bool, delegate: PatientRecomandationsHeaderViewDelegate) {
        self.patient = patient
        self.delegate = delegate
        
        
        let numberOfRecs = patient.recommandationsArray.compactMap({$0.immunizationDetail?.recommendation?.recommendedVaccinations}).filter({!$0.removeWhiteSpaceFormatting.isEmpty}).count

        nameLabel.text = patient.name
        style(enabled: numberOfRecs != 0)
        numerOfRecommendations.text = "\(numberOfRecs)"
        if patient.isDependent() {
            userLogoImageView.image = numberOfRecs == 0 ? UIImage(named: "dependentRecDisabled") : UIImage(named: "dependentRec")
        } else {
            userLogoImageView.image =  numberOfRecs == 0 ? UIImage(named: "primaryUserRecDisabled") : UIImage(named: "primaryUserRec")
        }
        
        arrowImageView.image = expanded ? UIImage(named: "expand_arrow_up") : UIImage(named: "expand_arrow_down")
        
        if numberOfRecs > 0 {
            arrowImageView.alpha = 1
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpand))
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(tapGesture)
        } else {
            arrowImageView.alpha = 0
        }
    }
    
    @objc func toggleExpand(sender : UITapGestureRecognizer) {
        guard let delegate = self.delegate, let patient = self.patient else {return}
        delegate.toggle(patient: patient)
    }
    
    func style(enabled: Bool) {
        nameLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        numerOfRecommendations.font = UIFont.bcSansBoldWithSize(size: 15)
        nameLabel.textColor = enabled ? AppColours.darkGreyText : AppColours.textGray
        numerOfRecommendations.textColor = enabled ? AppColours.appBlue : AppColours.textGray
        contentContainer.layer.cornerRadius = 4
        backgroundColor = .white
        contentContainer.backgroundColor = .clear
        contentContainer.layer.backgroundColor = UIColor.white.cgColor
        contentContainer.layer.shadowColor = UIColor.gray.cgColor
        contentContainer.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        contentContainer.layer.shadowRadius = 4.0
        contentContainer.layer.shadowOpacity = 0.2
        contentContainer.layer.masksToBounds = false
    }
}
