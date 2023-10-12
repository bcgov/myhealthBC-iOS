//
//  CovidTestResultBannerTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-06-30.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class CovidTestResultBannerTableViewCell: BaseHeaderTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var testDateLabel: UILabel!
    
    func setup(for model: TestResult, status: String) {
        backgroundColor = model.resultType.getColor
        statusLabel.textColor = model.resultType.getResultTextColor
        statusLabel.text = status
        nameLabel.text = model.patientDisplayName
        if let date = model.collectionDateTime {
            testDateLabel.text = "Tested on: \(date.issuedOnDateTimeWithAmPm)"
        } else {
            testDateLabel.text = ""
        }
        style()
    }
    
    private func style() {
        layer.cornerRadius = 4
        nameLabel.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
        statusLabel.font = UIFont.bcSansBoldWithSize(size: largeFontSize)
        testDateLabel.font = UIFont.bcSansRegularWithSize(size: smallFontSize)
    }
    
}
