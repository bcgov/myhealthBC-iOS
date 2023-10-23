//
//  UserRecordListView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-10.

// NOTE: This is for an individual's
import UIKit
// FIXME: NEED TO LOCALIZE 
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
        // TODO: put in AppColours
        greyRoundedBackgroundView.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
        greyRoundedBackgroundView.layer.cornerRadius = 4.0
        greyRoundedBackgroundView.layer.masksToBounds = true
        rightArrowImageView.image = UIImage(named: "resource-arrow")?.withRenderingMode(.alwaysTemplate)
        // TODO: put in AppColours
        rightArrowImageView.tintColor = UIColor(red: 0, green: 0.2, blue: 0.4, alpha: 1)
        recordTypeTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        recordTypeTitleLabel.textColor = AppColours.lightBlueText
        recordTypeSubtitleLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        recordTypeSubtitleLabel.textColor = AppColours.greyText
        self.layoutIfNeeded()
    }
    
    func configure(record: HealthRecordsDetailDataSource) {
        self.type = record.type
        iconImageView.image = record.image
        recordTypeTitleLabel.text = record.title
        var statusToInclude: String?
        switch record.type {
        case .covidImmunizationRecord:
            statusToInclude = nil
        case .covidTestResultRecord:
            statusToInclude = record.mainRecord?.listStatus
        case .medication:
            statusToInclude = record.mainRecord?.listStatus
        case .pharmacist:
            statusToInclude = record.mainRecord?.listStatus
        case .immunization:
            statusToInclude = record.mainRecord?.listStatus
        case .healthVisit:
            statusToInclude = record.mainRecord?.listStatus
        case .specialAuthorityDrug:
            statusToInclude = record.mainRecord?.listStatus
        case .laboratoryOrder:
            // I think we should use model.orderStatus?
            switch record.mainRecord?.status?.lowercased() {
            case "held", "pending", "partial":
                statusToInclude = "Pending"
            case "complete", "completed":
                statusToInclude = "Completed"
            case "cancelled":
                statusToInclude = "Cancelled"
            default:
                statusToInclude = record.mainRecord?.status ?? ""
            }
        case .hospitalVisit:
            statusToInclude = record.mainRecord?.listStatus
        case .clinicalDocument:
            statusToInclude = record.mainRecord?.listStatus
        case .diagnosticImaging:
            statusToInclude = record.mainRecord?.listStatus
        case .note:
            statusToInclude = record.mainRecord?.listStatus
        }
        
        switch record.type {
        case .hospitalVisit, .clinicalDocument:
            // records that dont show date
            recordTypeSubtitleLabel.text = statusToInclude
        case .covidImmunizationRecord, .covidTestResultRecord, .medication, .pharmacist, .healthVisit, .specialAuthorityDrug, .laboratoryOrder, .immunization, .diagnosticImaging, .note:
            // records that show date
            var text: String
            if let statusToInclude = statusToInclude, statusToInclude.trimWhiteSpacesAndNewLines.count > 0 {
                text = "\(statusToInclude) • "
            } else {
                text = ""
            }
            recordTypeSubtitleLabel.text = "\(text)\(record.mainRecord?.date ?? "")"
        }
        setupAccessibility()
        layoutIfNeeded()
    }
    
    // TODO: Setup accessibility
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = recordTypeTitleLabel.text
        self.accessibilityValue = recordTypeSubtitleLabel.text
        self.accessibilityHint = AccessibilityLabels.UserRecord.cardHint
    }
}
