//
//  ReccomandationTableViewCell.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-08-23.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class ReccomandationTableViewCell: UITableViewCell {

    @IBOutlet weak var cardContainer: UIView!
    
   
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandIconImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIStackView!
    @IBOutlet weak var iconSize: NSLayoutConstraint!
    @IBOutlet weak var stackLeading: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusValueLabel: UILabel!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDateValueLabel: UILabel!
    @IBOutlet weak var detailStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(object: ImmunizationRecommendation, expanded: Bool) {
        if expanded {
            detailStack.isHidden = false
            expandIconImageView.image = UIImage(named: "expand_arrow_up")
        } else {
            detailStack.isHidden = true
            expandIconImageView.image = UIImage(named: "expand_arrow_down")
        }
        titleLabel.text = object.immunizationDetail?.recommendation?.recommendedVaccinations
        if let immunizationName =  object.immunizationDetail?.recommendation?.recommendedVaccinations {
            titleLabel.text = immunizationName
        } else {
            titleLabel.text = object.immunizationDetail?.name ?? object.immunizationDetail?.agents.first?.name ?? "--"
        }
        
        statusValueLabel.text = object.status
        dueDateValueLabel.text = object.agentDueDate?.forecastDueDate
        
        styleStatus(text: object.status ?? "")
        
        style()
        layoutIfNeeded()
    }
    
    func styleStatus(text: String) {
        switch text.lowercased() {
        case "eligible":
            statusValueLabel.textColor = AppColours.green
            statusIcon.image = UIImage(named: "reccomandation-list-icon")
            iconSize.constant = 21
            stackLeading.constant = 20
        case "overdue":
            statusValueLabel.textColor = AppColours.appRed
            statusIcon.image = UIImage(named: "reccomandation-list-icon")
            iconSize.constant = 21
            stackLeading.constant = 20
        case "completed":
            statusValueLabel.textColor = AppColours.greyText
            statusIcon.image = UIImage(named: "reccomandation-list-icon-completed")
            iconSize.constant = 34
            stackLeading.constant = 8
        default:
            statusValueLabel.textColor = AppColours.greyText
            statusIcon.image = UIImage(named: "reccomandation-list-icon")
            iconSize.constant = 21
            stackLeading.constant = 20
        }
    }
    
    func style() {
        statusLabel.text = "Status: "
        dueDateLabel.text = "Due date: "
        statusLabel.textColor = AppColours.greyText
        dueDateValueLabel.textColor = AppColours.greyText
        titleLabel.textColor = AppColours.appBlue
        
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        statusLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        dueDateLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        statusValueLabel.font = UIFont.bcSansBoldWithSize(size: 13)
        dueDateValueLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        
        cardContainer.layer.cornerRadius = 4
        cardContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        cardContainer.layer.shadowOpacity = 1
        cardContainer.layer.shadowOffset = CGSize(width: -1, height: 5)
        cardContainer.layer.shadowRadius = 5
        layoutIfNeeded()
    }
}
