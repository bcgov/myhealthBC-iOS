//
//  ProfileDetailsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-01-27.
//

import UIKit

protocol ProfileDetailsTableViewCellDelegate: AnyObject {
    func addressHelpButtonTapped()
}

class ProfileDetailsTableViewCell: UITableViewCell {
    
    enum ViewType {
        case firstName
        case lastName
        case phn
        case physicalAddress
        case mailingAddress
        
        var getCellHeaderTitle: String {
            switch self {
            case .firstName:
                return "First name"
            case .lastName:
                return "Last name"
            case .phn:
                return "Personal Health Number (PHN)"
            case .physicalAddress:
                return "Physical Address"
            case .mailingAddress:
                return "Mailing Address"
            }
        }
        
        var isAddressCell: Bool {
            switch self {
            case .firstName, .lastName, .phn:
                return false
            case .physicalAddress, .mailingAddress:
                return true
            }
        }
    }
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var addressHelpTextLabel: UILabel!
    @IBOutlet private weak var addressHelpButton: UIButton!
    
    private weak var delegate: ProfileDetailsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyCellHeaderTextFormatting()
    }
    
    private func applyCellHeaderTextFormatting() {
        headerLabel.font = UIFont.bcSansRegularWithSize(size: 14)
        headerLabel.textColor = AppColours.textBlack
    }
    
    func configure(data: String?, type: ViewType, delegateOwner: UIViewController) {
        headerLabel.text = type.getCellHeaderTitle
        detailLabel.text = data
        addressHelpTextLabel.isHidden = !type.isAddressCell
        addressHelpButton.isHidden = !type.isAddressCell
        
        if type.isAddressCell {
            self.delegate = delegateOwner as? ProfileDetailsTableViewCellDelegate
            detailLabel.text = data == nil ? "No address on record" : data
            addressHelpTextLabel.text = data == nil ? "To add an address, visit" : "If this address is incorrect, please update it"
            let buttonTitle: NSAttributedString = data == nil ? applyLightButtonFormatting(text: "this page") : applyDarkButtonFormatting(text: "here")
            addressHelpButton.setAttributedTitle(buttonTitle, for: .normal)
            
            if data == nil {
                applyLightGreyFormatting(label: detailLabel, fontSize: 13)
                applyNormalFormatting(label: addressHelpTextLabel, fontSize: 13)
            } else {
                applyNormalFormatting(label: detailLabel, fontSize: 17)
                applyLightGreyFormatting(label: addressHelpTextLabel, fontSize: 13)
            }
        } else {
            applyNormalFormatting(label: detailLabel, fontSize: 17)
        }
    }
    
    private func applyNormalFormatting(label: UILabel, fontSize: CGFloat) {
        label.font = UIFont.bcSansRegularWithSize(size: fontSize)
        label.textColor = AppColours.textBlack
    }
    
    private func applyLightGreyFormatting(label: UILabel, fontSize: CGFloat) {
        label.font = UIFont.bcSansRegularWithSize(size: 13)
        label.textColor = AppColours.textGray
    }
    
    private func applyLightButtonFormatting(text: String) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.bcSansRegularWithSize(size: 13),
            NSAttributedString.Key.foregroundColor: AppColours.appBlue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        return attributedString
    }
    
    private func applyDarkButtonFormatting(text: String) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.bcSansBoldWithSize(size: 13),
            NSAttributedString.Key.foregroundColor: AppColours.appBlue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        return attributedString
    }
    
    @IBAction private func addressHelpButtonTapped(_ sender: Any) {
        self.delegate?.addressHelpButtonTapped()
    }
    
}
