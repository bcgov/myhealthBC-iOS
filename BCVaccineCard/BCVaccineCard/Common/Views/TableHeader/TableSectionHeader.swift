//
//  TableSectionHeader.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-09.
//

import UIKit

class TableSectionHeader: UIView {

    @IBOutlet weak var label: UILabel!
    
    
    func configure(text: String) {
        label.text = text
        backgroundColor = .clear
        label.textColor = UIColor(red: 0.192, green: 0.192, blue: 0.196, alpha: 1)
        label.font = UIFont.bcSansBoldWithSize(size: 17)
    }
}
