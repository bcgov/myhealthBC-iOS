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
        contentView.addSubview(stackView)
        stackView.addEqualSizeContraints(to: self.contentView)
        
        for recommendation in patient.recommandationsArray {
            let recommendationView: PatientRecommendationStack = PatientRecommendationStack.fromNib()
            stackView.addArrangedSubview(recommendationView)
            recommendationView.configure(immunizationName: recommendation.recommendedVaccinations, dueDate: recommendation.agentDueDate, descrtiptionText: recommendation.status)
        }
        backgroundColor = .orange.withAlphaComponent(0.3)
    }
    
}
