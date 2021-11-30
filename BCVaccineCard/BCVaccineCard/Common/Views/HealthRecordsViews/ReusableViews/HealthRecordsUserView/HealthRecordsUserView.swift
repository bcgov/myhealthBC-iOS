//
//  HealthRecordsUserView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
// https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=3275%3A42476
// This is just the text component

import UIKit

class HealthRecordsUserView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var recordCountLabel: UILabel!
    @IBOutlet weak var recordIconImageView: UIImageView!
    
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
        Bundle.main.loadNibNamed(HealthRecordsUserView.getName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        uiSetup()
    }
    
    private func uiSetup() {
        borderView.backgroundColor = AppColours.borderGray
        borderView.layer.cornerRadius = 4.0
        borderView.layer.masksToBounds = true
        nameLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        nameLabel.textColor = AppColours.appBlue
        recordCountLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        recordCountLabel.textColor = AppColours.textBlack
        recordIconImageView.image = UIImage(named: "vaccine-record-icon")
    }
    
    // TODO: Perhaps we need a user model here to configure this? User object which contains all of the different records that a user will have?
    func configure(name: String, records: Int) {
        setupAccessibility()
        // TODO: Add in a model to pass into configure and then adjust values
        nameLabel.text = name
        var recordText = "\(records) " + .recordText
        if records != 1 {
            recordText.append("s")
        }
        recordCountLabel.text = recordText
        
    }
    
    // TODO: Setup accessibility
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        let accessibilityLabel = ""
        self.accessibilityLabel = accessibilityLabel
//        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), \(AccessibilityLabels.VaccineCardView.qrCodeImage)" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
//        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = ""
    }
}
