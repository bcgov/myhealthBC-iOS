//
//  VaccineCardView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-06.
//

import UIKit

class VaccineCardView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var vaccineStatusLabel: UILabel!
    @IBOutlet weak var issuedOnLabel: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var tapToZoomInLabel: UILabel!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var expandableBackgroundView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(VaccineCardView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
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
        self.isAccessibilityElement = true
    }
    
    private func setupAccessibility(model: AppVaccinePassportModel, expanded: Bool, editMode: Bool) {
        let accessibilityLabel = expanded ? "Vaccination Card Expanded" : "Vaccination Card Collapsed"
        self.accessibilityLabel = accessibilityLabel
        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), QR code image" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = editMode ? "In edit mode: Swipe up or down for special actions, and you can unlink a card or adjust the order of your cards" : (expanded ? "Action Available: Tap to zoom in QR code" : "Action Available: Tap to expand Vaccination Card")
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
        setupAccessibility(model: model, expanded: expanded, editMode: editMode)
    }
}
