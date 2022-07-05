//
//  InteractiveLabelTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-01.
//

import UIKit


class InteractiveLabelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var clickableLabel: InteractiveLinkLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(string: String, linkedStrings: [LinkedStrings], textColor: UIColor, font: UIFont) {
        clickableLabel.attributedText = clickableLabel.attributedText(withString: string, linkedStrings: linkedStrings, textColor: textColor, font: font)
    }
}
