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
        case medication
        case laboratoryOrder
        case immunization
        case healthVisit
        case SpecialAuthority
        case hospitalVisit
        case clinicalDocument
        case diagnosticImaging
        case note
        
        var getTitle: String {
            switch self {
            case .covidImmunizationRecord: return .getVaccinationRecordsTitle
            case .covidTestResult: return .getCovidTestResultsTitle
            case .medication:
                return ""
            case .laboratoryOrder:
                return ""
            case .immunization:
                return ""
            case .healthVisit:
                return ""
            case .SpecialAuthority:
                return ""
            case .hospitalVisit:
                return ""
            case .clinicalDocument:
                return ""
            case .diagnosticImaging:
                return ""
            case .note:
                return ""
            }
        }
        
        var getDescription: String {
            switch self {
            case .covidImmunizationRecord: return .getVaccinationRecordsDescription
            case .covidTestResult: return .getCovidTestResultsDescription
            case .immunization:
                return ""
            case .medication:
                return ""
            case .laboratoryOrder:
                return ""
            case .healthVisit:
                return ""
            case .SpecialAuthority:
                return ""
            case .hospitalVisit:
                return ""
            case .clinicalDocument:
                return ""
            case .diagnosticImaging:
                return ""
            case .note:
                return ""
            }
        }
        
        var getImage: UIImage? {
            switch self {
            case .immunization: return UIImage(named: "vaccine-record-icon")
            case .covidImmunizationRecord: return UIImage(named: "vaccine-record-icon")
            case .covidTestResult: return UIImage(named: "test-result-icon")
            case .medication:
                return nil
            case .laboratoryOrder:
                return nil
            case .healthVisit:
                return nil
            case .SpecialAuthority:
                return nil
            case .hospitalVisit:
                return nil
            case .clinicalDocument:
                return nil
            case .diagnosticImaging:
                return nil
            case .note:
                return nil
            }
        }
    }
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var backgroundWhiteView: UIView!
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
        uiSetup()
    }
    
    private func uiSetup() {
        backgroundWhiteView.layer.masksToBounds = true
        backgroundWhiteView.layer.borderWidth = 1
        backgroundWhiteView.layer.borderColor = AppColours.borderGray.cgColor
        backgroundWhiteView.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        titleLabel.textColor = AppColours.appBlue
        descriptionLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        descriptionLabel.textColor = AppColours.textBlack
        addButtonImageView.image = UIImage(named: "add-card-icon")
    }
    
    func configure(type: RecordType) {
        self.type = type
        titleLabel.text = type.getTitle
        descriptionLabel.text = type.getDescription
        recordTypeImageView.image = type.getImage
        setupAccessibility()
    }
    
    // TODO: Setup accessibility
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = titleLabel.text
        self.accessibilityHint = descriptionLabel.text
        self.accessibilityTraits = .button
    }
}


