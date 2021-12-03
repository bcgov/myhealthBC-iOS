//
//  BannerViewTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
//

import UIKit

class BannerViewTableViewCell: UITableViewCell {
    
    weak var bannerView: StatusBannerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(type: HealthRecordsDetailDataSource.RecordType) {
        switch type {
        case .covidImmunizationRecord(let model, _):
            setup(vaccinePassport: model)
        case .covidTestResult(let model):
            setup(testResult: model)
        }
    }
    
    /// Setup cell for a Vaccine Record
    /// - Parameter model: Local Model
    func setup(vaccinePassport model: LocallyStoredVaccinePassportModel) {
        self.bannerView = createView()
        let statusImage: UIImage? = model.status == .fully ? UIImage(named: "check-mark") : nil
        let textColor = UIColor.white
        let backgroundColor = model.status.getColor
        let statusColor = textColor
        let date = Date.init(timeIntervalSince1970: model.issueDate)
        let issueDate = "Issued on: \(date.yearMonthDayString)"
        bannerView?.setup(in: self,
                          type: .VaccineRecord,
                          name: model.name,
                          status: model.status.getTitle,
                          date: issueDate,
                          backgroundColor: backgroundColor,
                          textColor: textColor,
                          statusColor: statusColor,
                          statusIconImage: statusImage)
    }
    
    /// Setup for test results
    /// - Parameter model: Local Model
    func setup(testResult model: LocallyStoredCovidTestResultModel) {
        self.bannerView = createView()
        let textColor = UIColor.black
        let backgroundColor = model.status.getColor
        let statusColor = model.status.getStatusTextColor
        var issueDate = ""
        if let date = model.response?.collectionDateTime {
            issueDate = "Tested on: \(date.yearMonthDayString)"
        }
        
        bannerView?.setup(in: self,
                          type: .CovidTest,
                          name: model.response?.patientDisplayName ?? "",
                          status: model.status.getTitle,
                          date: issueDate,
                          backgroundColor: backgroundColor,
                          textColor: textColor,
                          statusColor: statusColor,
                          statusIconImage: nil)
        
    }
    
    private func createView() -> StatusBannerView {
        if let existing = self.bannerView {existing.removeFromSuperview()}
        let banner: StatusBannerView = UIView.fromNib()
        return banner
    }
    
}
