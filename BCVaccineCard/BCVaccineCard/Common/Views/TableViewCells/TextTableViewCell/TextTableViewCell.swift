//
//  TextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

enum TextCellType {
    case plainText, underlinedWithImage
    
    var getImage: UIImage? {
        switch self {
        case .plainText: return nil
        case .underlinedWithImage: return #imageLiteral(resourceName: "info-icon")
        }
    }
}

class TextTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var cellTextLabel: UILabel!
    @IBOutlet weak private var leadingImageView: UIImageView!
    @IBOutlet weak private var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textLabelLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(forType type: TextCellType, text: String) {
        formatCell(type: type, text: text)
        
    }
    
    private func formatCell(type: TextCellType, text: String) {
        leadingImageView.isHidden = type == .plainText
        imageViewWidthConstraint.constant = type == .plainText ? 0 : 14
        textLabelLeadingConstraint.constant = type == .plainText ? 0 : 3
        if type == .underlinedWithImage {
            formatUnderlinedText(text: text)
            leadingImageView.image = type.getImage
        } else {
            cellTextLabel.text = text
            // TODO: Set font and colour here
        }
    }
    
    private func formatUnderlinedText(text: String) {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: text, attributes: underlineAttribute)
        // TODO: Add font and colour to the attributed string
        cellTextLabel.attributedText = underlineAttributedString
    }
    
}
