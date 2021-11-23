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
    @IBOutlet var qrImageConstraints: [NSLayoutConstraint]!
    
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
    }
    
    private func setupAccessibility(model: AppVaccinePassportModel, expanded: Bool, editMode: Bool) {
        self.isAccessibilityElement = true
        let accessibilityLabel = expanded ? AccessibilityLabels.VaccineCardView.vaccineCardExpanded : AccessibilityLabels.VaccineCardView.vaccineCardCollapsed
        self.accessibilityLabel = accessibilityLabel
        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), \(AccessibilityLabels.VaccineCardView.qrCodeImage)" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = editMode ? AccessibilityLabels.VaccineCardView.inEditMode : (expanded ? AccessibilityLabels.VaccineCardView.expandedAction : AccessibilityLabels.VaccineCardView.collapsedAction)
    }
    
    func configure(model: AppVaccinePassportModel, expanded: Bool, editMode: Bool) {
        self.isAccessibilityElement = false
        nameLabel.text = model.codableModel.name.uppercased()
        checkmarkImageView.isHidden = model.codableModel.status != .fully
        vaccineStatusLabel.text = model.codableModel.status.getTitle
        if let issuedOnDate = model.issueDate {
            issuedOnLabel.text = .issuedOn + issuedOnDate
        }
        issuedOnLabel.isHidden = model.issueDate == nil
        statusBackgroundView.backgroundColor = model.codableModel.status.getColor
        expandableBackgroundView.backgroundColor = model.codableModel.status.getColor
//        qrImageConstraints.forEach { $0.constant = model.codableModel.source == .healthGateway ? 0 : 6 }
        qrCodeImage.image = model.image
        expandableBackgroundView.isHidden = !expanded
        setupAccessibility(model: model, expanded: expanded, editMode: editMode)
    }
}
