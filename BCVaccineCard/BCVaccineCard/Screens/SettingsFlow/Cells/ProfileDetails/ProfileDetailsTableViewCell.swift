//
//  ProfileDetailsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-01-27.
//

import UIKit

protocol ProfileDetailsTableViewCellDelegate: AnyObject {
    func addressHelpButtonTapped(viewType: ProfileDetailsTableViewCell.ViewType)
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
        // TODO:
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
            let buttonTitle = data == nil ? "this page" : "here"
            addressHelpButton.setTitle(buttonTitle, for: .normal)
            
            if data == nil {
                applyLightGreyFormatting(label: detailLabel)
                applyNormalFormatting(label: addressHelpTextLabel)
                applyLightButtonFormatting(button: addressHelpButton)
            } else {
                applyNormalFormatting(label: detailLabel)
                applyLightGreyFormatting(label: addressHelpTextLabel)
                applyDarkButtonFormatting(button: addressHelpButton)
            }
        }
    }
    
    private func applyNormalFormatting(label: UILabel) {
        // TODO:
    }
    
    private func applyLightGreyFormatting(label: UILabel) {
        // TODO:
    }
    
    private func applyLightButtonFormatting(button: UIButton) {
        // TODO:
    }
    
    private func applyDarkButtonFormatting(button: UIButton) {
        // TODO:
    }
    
    @IBAction private func addressHelpButtonTapped(_ sender: Any) {
        // TODO:
    }
    
}
