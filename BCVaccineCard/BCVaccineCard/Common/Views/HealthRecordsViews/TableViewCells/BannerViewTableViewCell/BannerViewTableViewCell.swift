//
//  BannerViewTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
//

import UIKit

extension HealthRecordsDetailDataSource.Record {
    func toBannerViewTableViewCell() -> BannerViewTableViewCell.ViewModel {
        switch type {
        case .covidImmunizationRecord(let model, _):
            let statusImage: UIImage? = model.status == .fully ? UIImage(named: "check-mark") : nil
            let textColor = UIColor.white
            let backgroundColor = model.status.getColor
            let statusColor = textColor
            let date = Date.init(timeIntervalSince1970: model.issueDate)
            let issueDate = "Issued on: \(date.yearMonthDayString)"
            return BannerViewTableViewCell.ViewModel(statusImage: statusImage, textColor: textColor, backgroundColor: backgroundColor, statusColor: statusColor, issueDate: issueDate, name: name ,status: status, type: .VaccineRecord)
        case .covidTestResultRecord(let model):
            let textColor = UIColor.black
            let backgroundColor = model.status.getColor
            let statusColor = model.status.getStatusTextColor
            var issueDate = ""
            if let date = model.collectionDateTime {
                issueDate = "Tested on: \(date.yearMonthDayString)"
            }
            return BannerViewTableViewCell.ViewModel(statusImage: nil, textColor: textColor, backgroundColor: backgroundColor, statusColor: statusColor, issueDate: issueDate, name: name ,status: status, type: .CovidTest)
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
        let name: String
        let status: String
        let type: StatusBannerView.RecordType
        
    }
    
    weak var bannerView: StatusBannerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(model: ViewModel) {
        self.bannerView = createView()
        bannerView?.setup(in: self,
                          type: model.type,
                          name: model.name,
                          status: model.status,
                          date: model.issueDate,
                          backgroundColor: model.backgroundColor,
                          textColor: model.textColor,
                          statusColor: model.statusColor,
                          statusIconImage: model.statusImage)
    }
    
    private func createView() -> StatusBannerView {
        if let existing = self.bannerView {existing.removeFromSuperview()}
        let banner: StatusBannerView = UIView.fromNib()
        return banner
    }
    
}
