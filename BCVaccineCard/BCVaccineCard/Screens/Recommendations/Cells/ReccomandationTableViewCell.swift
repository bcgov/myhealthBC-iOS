//
//  ReccomandationTableViewCell.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-08-23.
//

import UIKit

class ReccomandationTableViewCell: UITableViewCell {

    @IBOutlet weak var cardContainer: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandIconImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIStackView!
    
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
        } else {
            detailStack.isHidden = true
        }
        titleLabel.text = object.immunizationDetail?.name
        statusValueLabel.text = object.status
        dueDateValueLabel.text = object.diseaseDueDate?.issuedOnDate
        
        cardContainer.layer.cornerRadius = 4
        cardContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        cardContainer.layer.shadowOpacity = 1
        cardContainer.layer.shadowOffset = CGSize(width: -1, height: 5)
        cardContainer.layer.shadowRadius = 5
    }
}
