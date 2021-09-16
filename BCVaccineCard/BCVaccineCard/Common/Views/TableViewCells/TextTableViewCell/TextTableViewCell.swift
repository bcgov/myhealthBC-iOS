//
//  TextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var cellTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(withText text: String) {
        cellTextLabel.text = text
    }
    
}
