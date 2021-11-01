//
//  TextTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
//

import UIKit

enum TextCellType: Equatable {
    case plainText, underlinedWithImage, partiallyBoldedText(boldTexts: [String], boldFont: UIFont)
    
    var getImage: UIImage? {
        switch self {
        case .plainText: return nil
        case .underlinedWithImage: return #imageLiteral(resourceName: "info-icon")
        case .partiallyBoldedText: return nil
        }
    }
}

class TextTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var cellTextLabel: UILabel!
    @IBOutlet weak private var leadingImageView: UIImageView!
    @IBOutlet weak private var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textLabelTrailingConstraint: NSLayoutConstraint!
    
    var type: TextCellType?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(forType type: TextCellType, text: String, withFont font: UIFont, labelSpacingAdjustment: CGFloat? = nil) {
        self.type = type
        formatCell(type: type, text: text, font: font)
        guard let constant = labelSpacingAdjustment else { return }
        adjustLabelSpacing(by: constant)
        self.accessibilityTraits = [.staticText]
        
    }
    
    private func formatCell(type: TextCellType, text: String, font: UIFont) {
        leadingImageView.isHidden = type != .underlinedWithImage
        imageViewWidthConstraint.constant = type != .underlinedWithImage ? 0 : 14
        textLabelLeadingConstraint.constant = type != .underlinedWithImage ? 0 : 3
        switch type {
        case .plainText:
            cellTextLabel.text = text
            cellTextLabel.font = font
            cellTextLabel.textColor = AppColours.textBlack
        case .underlinedWithImage:
            formatUnderlinedText(text: text, font: font)
            leadingImageView.image = type.getImage
        case .partiallyBoldedText(let boldTexts, let boldFont):
            cellTextLabel.attributedText = attributedText(withString: text, boldStrings: boldTexts, normalFont: font, boldFont: boldFont, textColor: AppColours.textBlack)
        }
    }
    
    private func formatUnderlinedText(text: String, font: UIFont) {
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.foregroundColor: AppColours.appBlue,
            NSAttributedString.Key.font: font
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        cellTextLabel.attributedText = attributedString
    }
    
    private func adjustLabelSpacing(by constant: CGFloat) {
        textLabelLeadingConstraint.constant = constant
        textLabelTrailingConstraint.constant = constant
    }
    
    private func attributedText(withString string: String, boldStrings: [String], normalFont: UIFont, boldFont: UIFont, textColor: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: normalFont, NSAttributedString.Key.foregroundColor: textColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: boldFont]
        for boldString in boldStrings {
            let range = (string as NSString).range(of: boldString)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }
        return attributedString
    }
    
}
