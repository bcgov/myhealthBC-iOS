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
        style()
        
        let numberOfRecs = patient.recommandationsArray.count
        nameLabel.text = patient.name
        numerOfRecommendations.text = "\(numberOfRecs)"
        userLogoImageView.image = patient.isDependent() ? UIImage(named: "dependentRec") : UIImage(named: "primaryUserRec")
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
    
    func style() {
        nameLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        numerOfRecommendations.font = UIFont.bcSansBoldWithSize(size: 15)
        nameLabel.textColor = UIColor(red: 0.192, green: 0.192, blue: 0.196, alpha: 1)
        numerOfRecommendations.textColor = AppColours.appBlue
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
