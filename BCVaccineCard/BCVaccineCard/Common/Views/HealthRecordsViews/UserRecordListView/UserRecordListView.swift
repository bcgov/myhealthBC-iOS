//
//  UserRecordListView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-10.
// https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=2411%3A24372
// NOTE: This is for an individual's
import UIKit
import CloudKit

class UserRecordListView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var greyRoundedBackgroundView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var recordTypeTitleLabel: UILabel!
    @IBOutlet weak private var recordTypeSubtitleLabel: UILabel! // This will include the status and the date
    @IBOutlet weak private var rightArrowImageView: UIImageView!
    
    var type: HealthRecordsDetailDataSource.RecordType!
    
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
        Bundle.main.loadNibNamed(UserRecordListView.getName, owner: self, options: nil)
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
        greyRoundedBackgroundView.backgroundColor = AppColours.backgroundGray
        greyRoundedBackgroundView.layer.cornerRadius = 4.0
        greyRoundedBackgroundView.layer.masksToBounds = true
        rightArrowImageView.image = UIImage(named: "resource-arrow")
        recordTypeTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        recordTypeTitleLabel.textColor = AppColours.appBlue
        recordTypeSubtitleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        recordTypeSubtitleLabel.textColor = AppColours.textBlack
    }
    
    func configure(record: HealthRecordsDetailDataSource) {
        self.type = record.type
        setupAccessibility()
        iconImageView.image = record.image
        recordTypeTitleLabel.text = record.title
        var subtitleString: String = record.mainRecord?.status ?? ""
        if let dateString = record.mainRecord?.status {
            let addition = " • " + dateString
            subtitleString.append(addition)
        }
        recordTypeSubtitleLabel.text = subtitleString
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
