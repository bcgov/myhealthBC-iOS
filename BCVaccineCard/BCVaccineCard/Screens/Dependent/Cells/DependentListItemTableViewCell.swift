//
//  DependentListItemTableViewCell.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-10-17.
//

import UIKit

class DependentListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(name: String) {
        nameLabel.text = name
        nameLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        nameLabel.textColor = AppColours.appBlue
        backgroundColor = .clear
        container.backgroundColor = AppColours.commentBackground
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
    }
    
}
