//
//  GetRecordsView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-10..
// https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=2411%3A24207
// NOTE: This is for the initial view on an empty health records screen (Get Vaccination Records, Get COVID-19 Test Results)
import UIKit

class GetRecordsView: UIView {
    
    enum RecordType {
        case covidImmunizationRecord
        case covidTestResult
        
        var getTitle: String {
            switch self {
            case .covidImmunizationRecord: return .getVaccinationRecordsTitle
            case .covidTestResult: return .getCovidTestResultsTitle
            }
        }
        
        var getDescription: String {
            switch self {
            case .covidImmunizationRecord: return .getVaccinationRecordsDescription
            case .covidTestResult: return .getCovidTestResultsDescription
            }
        }
        
        var getImage: UIImage? {
            switch self {
            case .covidImmunizationRecord: return UIImage(named: "vaccine-record-icon")
            case .covidTestResult: return UIImage(named: "test-result-icon")
            }
        }
    }
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var backgroundGreyRoundedView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var recordTypeImageView: UIImageView!
    @IBOutlet weak private var addButtonImageView: UIImageView!
    
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
        Bundle.main.loadNibNamed(GetRecordsView.getName, owner: self, options: nil)
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
        backgroundGreyRoundedView.backgroundColor = AppColours.borderGray
        backgroundGreyRoundedView.layer.cornerRadius = 4.0
        backgroundGreyRoundedView.layer.masksToBounds = true
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        titleLabel.textColor = AppColours.appBlue
        descriptionLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        descriptionLabel.textColor = AppColours.textBlack
        addButtonImageView.image = UIImage(named: "add-card-icon")
    }
    
    func configure(type: RecordType) {
        self.type = type
        setupAccessibility()
        titleLabel.text = type.getTitle
        descriptionLabel.text = type.getDescription
        recordTypeImageView.image = type.getImage
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

