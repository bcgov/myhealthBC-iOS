//
//  SeparatorTableViewCell.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-06-29.
//

import UIKit

class SeparatorTableViewCell: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = UIColor(red: 0.812, green: 0.812, blue: 0.812, alpha: 1)
    }
    
}
