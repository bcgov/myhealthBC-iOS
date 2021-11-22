//
//  InteractiveLabelTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-01.
//

import UIKit

struct LinkedStrings: Equatable {
    let text: String
    let link: String
}

class InteractiveLabelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var clickableLabel: InteractiveLinkLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(string: String, linkedStrings: [LinkedStrings], textColor: UIColor, font: UIFont) {
        clickableLabel.attributedText = attributedText(withString: string, linkedStrings: linkedStrings, textColor: textColor, font: font)
    }
    
    private func attributedText(withString string: String, linkedStrings: [LinkedStrings], textColor: UIColor, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: font])
        for linkedString in linkedStrings {
            let range = (string as NSString).range(of: linkedString.text)
            if let url = URL(string: linkedString.link) {
                let linkAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.link: url]
                attributedString.addAttributes(linkAttribute, range: range)
            } 
        }
        return attributedString
    }
    
}
