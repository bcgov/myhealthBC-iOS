//
//  ImmunizationForecastTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-07-19.
//

import UIKit

class ImmunizationForecastTableViewCell: UITableViewCell {
    
    enum Status {
        case Eligible
        case Overdue
    }

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusHeader: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dueDateHeader: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    func setup(forecast: ImmunizationForecast?) {
        guard let forecast = forecast, let status = forecast.status?.forecastStatus() else {return}
        setup(for: forecast, status: status)
        style()
    }
    
    private func setup(for forecast: ImmunizationForecast, status: Status) {
        switch status {
        case .Eligible:
            imageView?.image = UIImage(named: "immunization-forecast-eligible")
            statusLabel.textColor = AppColours.green
        case .Overdue:
            imageView?.image = UIImage(named: "immunization-forecast-overdue")
            statusLabel.textColor = AppColours.greyText
        }
        dueDateLabel.text = forecast.dueDate?.forecastDueDate ?? "--"
        statusLabel.text = forecast.status ?? "--"
        titleLabel.text = forecast.displayName
        
    }
    
    func style() {
        dueDateHeader.textColor = AppColours.greyText
        statusHeader.textColor = AppColours.greyText
        dueDateLabel.textColor = AppColours.greyText
        statusLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        statusHeader.font = UIFont.bcSansRegularWithSize(size: 13)
        dueDateLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        dueDateHeader.font = UIFont.bcSansRegularWithSize(size: 13)
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        titleLabel.textColor = .black
        layoutIfNeeded()

        container.layer.cornerRadius = 4
        container.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = CGSize(width: -1, height: 5)
        container.layer.shadowRadius = 5
    }
    
}

fileprivate extension String {
    func forecastStatus() -> ImmunizationForecastTableViewCell.Status? {
        switch self.lowercased() {
        case "eligible":
            return .Eligible
        case "overdue":
            return .Overdue
        default:
            return .Overdue
        }
    }
}
