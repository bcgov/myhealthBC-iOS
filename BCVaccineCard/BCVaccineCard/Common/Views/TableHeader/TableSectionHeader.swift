//
//  TableSectionHeader.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-09.
//

import UIKit

class TableSectionHeader: UIView {
    static let font = UIFont.bcSansBoldWithSize(size: 17)

    @IBOutlet weak var label: UILabel!
    
    func configure(text: String) {
        label.text = text
        backgroundColor = .clear
        // TODO: put in AppColours
        label.textColor = AppColours.darkGreyText
        label.font = TableSectionHeader.font
    }
}
