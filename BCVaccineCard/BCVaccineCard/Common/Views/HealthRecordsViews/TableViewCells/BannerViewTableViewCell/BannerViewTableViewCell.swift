//
//  BannerViewTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
//

import UIKit
import BCVaccineValidator

extension ImmunizationStatus {
    
    func toCovidTestResult() -> VaccineStatus {
        switch self {
        case .Fully:
            return .fully
        case .Partially:
            return .partially
        case .None:
            return .notVaxed
        }
    }
}

extension HealthRecordsDetailDataSource.Record {
    fileprivate func statusBannerViewType() -> StatusBannerView.BannerType {
        switch self.type {
        case .covidImmunizationRecord:
            return .VaccineRecord
        case .covidTestResultRecord:
            var type = StatusBannerView.BannerType.CovidTest
            if status?.lowercased() == .pending.lowercased() {
                type = .Message
            }
            
            if status?.lowercased() == .cancelled.lowercased() {
                type = .Message
            }
            return type
        case .medication, .laboratoryOrder:
            return .NoBanner
        }
    }
    
    func toBannerViewTableViewCellViewModel(completion: @escaping(BannerViewTableViewCell.ViewModel?)->Void) {
        switch type {
        case .covidImmunizationRecord(let model, _):
            let textColor = UIColor.white
            let statusColor = textColor
            let date = Date.init(timeIntervalSince1970: model.issueDate)
            let issueDate = "Issued on: \(date.issuedOnDateTime)"
            BCVaccineValidator.shared.validate(code: model.code) { validationResult in
                guard let result = validationResult.result else {return completion(nil)}
                let statusImage: UIImage? = result.status == .Fully ? UIImage(named: "check-mark") : nil
                let status = result.status.toCovidTestResult().getTitle
                let backgroundColor = result.status.toCovidTestResult().getColor
                DispatchQueue.main.async {
                    return completion(BannerViewTableViewCell.ViewModel(statusImage: statusImage, textColor: textColor, backgroundColor: backgroundColor, statusColor: statusColor, issueDate: issueDate, name: name, status: status, type: .VaccineRecord, attributedString: nil))
                }
            }
            
        case .covidTestResultRecord(let model):
            let textColor = UIColor.black
            let backgroundColor = model.resultType.getColor
            let statusColor = model.resultType.getResultTextColor
            var issueDate = ""
            if let date = model.collectionDateTime {
                issueDate = "Tested on: \(date.issuedOnDateTime)"
            }
            var attributedString: NSMutableAttributedString? = nil
            var name: String? = name
            var type = StatusBannerView.BannerType.CovidTest
            if status?.lowercased() == .pending.lowercased() {
                type = .Message
                name = nil
                attributedString = NSMutableAttributedString(string: .pendingTestRecordMessage)
            }
            
            if status?.lowercased() == .cancelled.lowercased() {
                type = .Message
                name = nil
                attributedString = NSMutableAttributedString(string: .cancelledTestRecordMessage)
                _ = attributedString?.setAsLink(textToFind: "BC CDC Test Results", linkURL: "http://www.bccdc.ca/health-info/diseases-conditions/covid-19/testing/test-results")
            }
            
            return completion(BannerViewTableViewCell.ViewModel(statusImage: nil, textColor: textColor, backgroundColor: backgroundColor, statusColor: statusColor, issueDate: issueDate, name: name ,status: status, type: type, attributedString: attributedString))
        case .medication, .laboratoryOrder:
            return completion(nil)
        }
    }
}

class BannerViewTableViewCell: UITableViewCell {
    
    struct ViewModel {
        let statusImage: UIImage?
        let textColor: UIColor
        let backgroundColor: UIColor
        let statusColor: UIColor
        let issueDate: String
        let name: String?
        let status: String?
        let type: StatusBannerView.BannerType
        let attributedString: NSMutableAttributedString?
    }
    
    weak var bannerView: StatusBannerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(record: HealthRecordsDetailDataSource.Record) {
        self.bannerView = createView()
        let type = record.statusBannerViewType()
        self.bannerView?.setup(in: self, type: type)
        self.bannerView?.alpha = 0
        self.startLoadingIndicator()
        record.toBannerViewTableViewCellViewModel { [weak self] model in
            guard let `self` = self, let model = model else {return}
            self.bannerView?.update(
                type: model.type,
                name: model.name,
                status: model.status ?? "",
                date: model.issueDate,
                backgroundColour: model.backgroundColor,
                textColour: model.textColor,
                statusColour: model.statusColor,
                statusIconImage: model.statusImage,
                attributedString: model.attributedString)
               
            self.endLoadingIndicator()
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {[weak self] in
                guard let `self` = self else {return}
                self.bannerView?.alpha = 1
                self.layoutIfNeeded()
            }
        }
        
    }
    
    private func createView() -> StatusBannerView {
        if let existing = self.bannerView {existing.removeFromSuperview()}
        let banner: StatusBannerView = UIView.fromNib()
        return banner
    }
    
}

extension HealthRecordsDetailDataSource.Record.RecordType {
    
    func toBannerType() -> StatusBannerView.BannerType {
        switch self {
        case .covidImmunizationRecord:
            return .VaccineRecord
        case .covidTestResultRecord:
            return .CovidTest
        case .medication, .laboratoryOrder:
            return .NoBanner
        }
    }
}
