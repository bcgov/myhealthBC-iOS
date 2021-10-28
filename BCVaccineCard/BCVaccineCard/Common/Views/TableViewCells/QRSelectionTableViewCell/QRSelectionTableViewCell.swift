//
//  QRSelectionTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

class QRSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var buttonView: TableViewButtonView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withStyle style: TableViewButtonView.ButtonStyle, buttonType: TableViewButtonView.ButtonType) {
        buttonView.configure(withStyle: style, buttonType: buttonType)
    }
    
}
