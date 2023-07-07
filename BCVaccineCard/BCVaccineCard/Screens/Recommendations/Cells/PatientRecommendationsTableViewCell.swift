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
        contentView.subviews.forEach({$0.removeFromSuperview()})
        contentView.addSubview(stackView)
        stackView.addEqualSizeContraints(to: self.contentView, paddingVertical: 14, paddingHorizontal: 17)
        
        for recommendation in patient.recommandationsArray {
            if let name = recommendation.immunizationDetail?.recommendation?.recommendedVaccinations,
               !name.removeWhiteSpaceFormatting.isEmpty {
                let recommendationView: PatientRecommendationStack = PatientRecommendationStack.fromNib()
                stackView.addArrangedSubview(recommendationView)
                recommendationView.configure(immunizationName: name, dueDate: recommendation.agentDueDate, descrtiptionText: recommendation.status)
            }
        }
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 20
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.backgroundColor = UIColor.white.cgColor
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.masksToBounds = false
    }
    
}
