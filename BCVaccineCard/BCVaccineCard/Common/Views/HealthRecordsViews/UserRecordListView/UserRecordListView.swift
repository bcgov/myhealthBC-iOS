//
//  UserRecordListView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-10.
// https://www.figma.com/file/ga1F6q5Kvi6CD6FLS27fXq/My-Health-BC?node-id=2411%3A24372
// NOTE: This is for an individual's
import UIKit
// TODO: Connor: This is a placeholder test status that you can delete as I'm sure you have already created a separate enum in a model class for this, then replace where errors pop up, accordingly
enum TestStatusForAmirToDelete: String, Codable {
    case pending = "pending", negative, positive, indeterminate, cancelled
    
    var getTitle: String {
        return self.rawValue.uppercased()
    }
}

class UserRecordListView: UIView {
    
    enum RecordType {
        case covidImmunizationRecord(status: VaccineStatus)
        case covidTestResult(status: TestStatusForAmirToDelete)
        
        var getTitle: String {
            switch self {
            case .covidImmunizationRecord: return .getVaccinationRecordsTitle
            case .covidTestResult: return .getCovidTestResultsTitle
            }
        }
        
        var getStatus: String {
            switch self {
            case .covidImmunizationRecord(let status): return status.getTitle
            case .covidTestResult(let status): return status.getTitle
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
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var recordTypeTitle: UILabel!
    
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
        
    }
    
    func configure() {
        setupAccessibility()
        // TODO: Fill in here
    }
    
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        let accessibilityLabel = ""
        self.accessibilityLabel = accessibilityLabel
//        let accessibilityValue = expanded ? "\(model.codableModel.name), \(model.codableModel.status.getTitle), \(model.getFormattedIssueDate()), \(AccessibilityLabels.VaccineCardView.qrCodeImage)" : "\(model.codableModel.name), \(model.codableModel.status.getTitle)"
//        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = ""
    }
}
