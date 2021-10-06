//
//  VaccineCardTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

class VaccineCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var vaccineStatusLabel: UILabel!
    @IBOutlet weak var issuedOnLabel: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var tapToZoomInLabel: UILabel!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var expandableBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        viewSetup()
        labelSetup()
    }
    
    private func labelSetup() {
        nameLabel.textColor = .white
        nameLabel.font = UIFont.bcSansBoldWithSize(size: 16)
        vaccineStatusLabel.textColor = .white
        vaccineStatusLabel.font = UIFont.bcSansRegularWithSize(size: 18)
        issuedOnLabel.textColor = .white
        issuedOnLabel.font = UIFont.bcSansRegularWithSize(size: 11)
        tapToZoomInLabel.textColor = .white
        tapToZoomInLabel.font = UIFont.bcSansBoldWithSize(size: 12)
        tapToZoomInLabel.text = .tapToZoomIn
    }
    
    private func viewSetup() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 6.0
        
        roundedView.layer.cornerRadius = 3
        roundedView.layer.masksToBounds = true
        
        self.isAccessibilityElement = true
        
    }
    
    private func adjustShadow(expanded: Bool) {
        shadowView.layer.shadowOpacity = expanded ? 0.7 : 0.0
    }
    
    func configure(model: AppVaccinePassportModel, expanded: Bool, editMode: Bool) {
        nameLabel.text = model.codableModel.name.uppercased()
        checkmarkImageView.isHidden = model.codableModel.status != .fully
        vaccineStatusLabel.text = model.codableModel.status.getTitle
        if let issuedOnDate = model.issueDate {
            issuedOnLabel.text = .issuedOn + issuedOnDate
        }
        issuedOnLabel.isHidden = model.issueDate == nil
        statusBackgroundView.backgroundColor = model.codableModel.status.getColor
        expandableBackgroundView.backgroundColor = model.codableModel.status.getColor
        qrCodeImage.image = model.image
        expandableBackgroundView.isHidden = !expanded
        adjustShadow(expanded: expanded)
        setupAccessibility(model: model, expanded: expanded, editMode: editMode)
    }
    
    private func setupAccessibility(model: AppVaccinePassportModel, expanded: Bool, editMode: Bool) {
        let accessibilityLabel = expanded ? "Vaccination Card Expanded" : "Vaccination Card Collapsed"
        self.accessibilityLabel = accessibilityLabel
        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), QR code image" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = editMode ? "In edit mode: Swipe up or down for special actions, and you can unlink a card or adjust the order of your cards" : (expanded ? "Action Available: Tap to zoom in QR code" : "Action Available: Tap to expand Vaccination Card")
    }
}
