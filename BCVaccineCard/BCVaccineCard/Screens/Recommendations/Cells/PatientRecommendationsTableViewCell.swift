//
//  PatientRecommendationsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-07-06.
//

import UIKit

class PatientRecommendationsTableViewCell: UITableViewCell {

    var patient: Patient? = nil
    
    func configure(patient: Patient) {
        self.patient = patient
        let stackView = UIStackView(frame: self.frame)
        let container = UIView(frame: self.frame)
        contentView.subviews.forEach({$0.removeFromSuperview()})
        contentView.addSubview(container)
//        contentView.addSubview(stackView)
        container.addSubview(stackView)
        container.addEqualSizeContraints(to: self.contentView, top: 0, bottom: 4, left: 4, right: 4)
        stackView.addEqualSizeContraints(to: container, paddingVertical: 14, paddingHorizontal: 17)
        
        for recommendation in patient.recommandationsArray {
            if let name = recommendation.immunizationDetail?.recommendation?.recommendedVaccinations,
               !name.removeWhiteSpaceFormatting.isEmpty {

                let recommendationView: PatientRecommendationStack = PatientRecommendationStack.fromNib()
                stackView.addArrangedSubview(recommendationView)
                recommendationView.configure(immunizationName: name, dueDate: recommendation.agentDueDate, descrtiptionText: recommendation.status, eligibleDate: recommendation.agentEligibleDate)
            }
        }
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 20
        container.backgroundColor = .white
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        container.layer.backgroundColor = UIColor.white.cgColor
        container.layer.shadowColor = UIColor.gray.cgColor
        container.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        container.layer.shadowRadius = 4.0
        container.layer.shadowOpacity = 0.2
        container.layer.masksToBounds = false
        layoutIfNeeded()
    }
    
}
