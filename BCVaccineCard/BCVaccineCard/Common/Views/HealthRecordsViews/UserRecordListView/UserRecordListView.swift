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
    
    enum RecordType {
        case covidImmunizationRecord(model: LocallyStoredVaccinePassportModel)
        case covidTestResult(model: LocallyStoredCovidTestResultModel)
        
        var getTitle: String {
            switch self {
            case .covidImmunizationRecord: return .covid19mRNATitle
            case .covidTestResult: return .covid19TestResultTitle
            }
        }
        
        var getStatus: String {
            switch self {
            case .covidImmunizationRecord(let model): return model.status.getTitle
            case .covidTestResult(let model): return model.status.getTitle
            }
        }
        
        var getDate: String? {
            switch self {
            case .covidImmunizationRecord(let model): return model.vaxDates.last
            case .covidTestResult(let model): return model.response?.resultDateTime?.monthDayYearString // TODO: Need to confirm formatting on this
            }
        }
        
        var getImage: UIImage? {
            switch self {
            case .covidImmunizationRecord: return UIImage(named: "blue-bg-vaccine-record-icon")
            case .covidTestResult: return UIImage(named: "blue-bg-test-result-icon")
            }
        }
    }
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var greyRoundedBackgroundView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var recordTypeTitleLabel: UILabel!
    @IBOutlet weak private var recordTypeSubtitleLabel: UILabel! // This will include the status and the date
    @IBOutlet weak private var rightArrowImageView: UIImageView!
    
    var type: RecordType!
    
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
    
    func configure(recordType: RecordType) {
        self.type = recordType
        setupAccessibility()
        iconImageView.image = recordType.getImage
        var subtitleString = recordType.getStatus
        if let dateString = recordType.getDate {
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
