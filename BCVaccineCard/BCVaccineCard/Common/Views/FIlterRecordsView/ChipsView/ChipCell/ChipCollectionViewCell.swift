//
//  ChipCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-10.
//

import UIKit

class ChipCollectionViewCell: UICollectionViewCell {
    static let textHeight: CGFloat = 31
    static let paddingVertical: CGFloat = 4
    static let paddingHorizontal: CGFloat = 12
    static let selectedFont = UIFont.bcSansBoldWithSize(size: 15)
    static let unselectedFont = UIFont.bcSansRegularWithSize(size: 15)

    @IBOutlet weak var textWidth: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var labelBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var labelLeadingContraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(text: String, selected: Bool) {
        label.text = text
        contentView.layer.cornerRadius = 5
        labelBottomContraint.constant = ChipCollectionViewCell.paddingVertical
        labelLeadingContraint.constant = ChipCollectionViewCell.paddingHorizontal
        if selected {
            styleSelected()
        } else {
            styleUnselected()
        }
    }
    
    func styleSelected() {
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = AppColours.appBlue.cgColor
        let font = ChipCollectionViewCell.selectedFont
        label.font = font
        label.textColor = AppColours.appBlue
        let text = label.text ?? ""
        textWidth.constant = text.widthForView(font: font, height: 31)
    }
    
    func styleUnselected() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppColours.appBlue.cgColor
        let font = ChipCollectionViewCell.unselectedFont
        label.font = font
        label.textColor = AppColours.appBlue
        let text = label.text ?? ""
        textWidth.constant = text.widthForView(font: font, height: 31)
    }

}
