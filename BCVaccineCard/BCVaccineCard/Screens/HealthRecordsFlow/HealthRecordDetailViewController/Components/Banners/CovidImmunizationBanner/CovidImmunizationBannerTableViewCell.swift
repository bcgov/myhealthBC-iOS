//
//  CovidImmunizationBannerTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-06-30.
//

import UIKit
import BCVaccineValidator

class CovidImmunizationBannerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    private var largeFontSize: CGFloat {
        if Device.IS_IPHONE_5 {
            return 16
        } else {
            return 18
        }
    }
    
    private var mediumFontSize: CGFloat {
        if Device.IS_IPHONE_5 {
            return 14
        } else {
            return 16
        }
    }
    
    private var smallFontSize: CGFloat {
        if Device.IS_IPHONE_5 {
            return 12
        } else {
            return 15
        }
    }
    
    func setup(model: LocallyStoredVaccinePassportModel) {
        style()
        startLoadingIndicator(backgroundColor: .white)
        setup(name: model.name, issue: Date.init(timeIntervalSince1970: model.issueDate), status: model.status)
        BCVaccineValidator.shared.validate(code: model.code) { [weak self] validationResult in
            guard let result = validationResult.result, let self = self else {return }
            self.endLoadingIndicator()
            self.setup(name: model.name, issue: Date.init(timeIntervalSince1970: model.issueDate), status: result.status.toVaccineStatus())
        }
    }
    
    private func setup(name: String, issue date: Date, status: VaccineStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.nameLabel.text = name
            self.timeLabel.text = "Issued on: \(date.issuedOnDateTime)"
            self.statusIcon.isHidden = status != .fully
            self.statusLabel.text = status.getTitle
            self.backgroundColor = status.getColor
        }
    }
    
    private func style() {
        clipsToBounds = true
        layer.cornerRadius = 5
        nameLabel.font = UIFont.bcSansBoldWithSize(size: mediumFontSize)
        statusLabel.font = UIFont.bcSansRegularWithSize(size: largeFontSize)
        timeLabel.font = UIFont.bcSansRegularWithSize(size: smallFontSize)
        nameLabel.textColor = .white
        statusLabel.textColor = .white
        timeLabel.textColor = .white
        statusIcon.tintColor = .white
    }
    
}


extension ImmunizationStatus {
    func toVaccineStatus() -> VaccineStatus {
        switch self {
        case .Fully:
            return .fully
        case .Partially:
            return .partially
        case .None:
            return .notVaxed
        }
    }
}
