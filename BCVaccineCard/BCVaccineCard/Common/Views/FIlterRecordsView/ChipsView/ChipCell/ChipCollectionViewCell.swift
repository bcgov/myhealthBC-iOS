//
//  ChipCollectionViewCell.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-10.
//

import UIKit

class ChipCollectionViewCell: UICollectionViewCell {
    static let textHeight: CGFloat = 28
    static let paddingVertical: CGFloat = 4
    static let paddingHorizontal: CGFloat = 12
    static let selectedFont = UIFont.bcSansBoldWithSize(size: 14)
    static let unselectedFont = UIFont.bcSansRegularWithSize(size: 15)
    static let selectedBackgroundColour = UIColor(red: 0.102, green: 0.353, blue: 0.588, alpha: 1)

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
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = ChipCollectionViewCell.selectedBackgroundColour.cgColor
        contentView.backgroundColor = ChipCollectionViewCell.selectedBackgroundColour
        let font = ChipCollectionViewCell.selectedFont
        label.font = font
        label.textColor = UIColor.white
        let text = label.text ?? ""
        textWidth.constant = text.widthForView(font: font, height: ChipCollectionViewCell.textHeight)
    }
    
    func styleUnselected() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppColours.appBlue.cgColor
        contentView.backgroundColor = .clear
        let font = ChipCollectionViewCell.unselectedFont
        label.font = font
        label.textColor = AppColours.appBlue
        let text = label.text ?? ""
        textWidth.constant = text.widthForView(font: font, height: ChipCollectionViewCell.textHeight)
    }

}
