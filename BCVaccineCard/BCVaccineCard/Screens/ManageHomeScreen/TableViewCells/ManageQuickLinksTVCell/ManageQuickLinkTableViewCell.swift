//
//  ManageQuickLinkTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-08-01.
//

import UIKit

protocol ManageQuickLinkTableViewCellDelegate: AnyObject {
    func checkboxTapped(enabled: Bool)
}

class ManageQuickLinkTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var roundedView: UIView!
    @IBOutlet private weak var quickLinkLabel: UILabel!
    @IBOutlet private weak var checkboxButton: UIButton!
    
    private weak var delegate: ManageQuickLinkTableViewCellDelegate?
    private var enabled = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        // TODO: UI setup here
    }
    
    func configure(quickLink: ManageHomeScreenViewController.QuickLinksNames, enabled: Bool, delegateOwner: UIViewController) {
        self.enabled = enabled
        quickLinkLabel.text = quickLink.getManageScreenDisplayableName
        setCheckboxButton(enabled: enabled)
        self.delegate = delegateOwner as? ManageQuickLinkTableViewCellDelegate
    }
    
    private func setCheckboxButton(enabled: Bool) {
        let image = enabled ? UIImage(named: "quick_checkbox_filled") : UIImage(named: "quick_checkbox_empty")
        checkboxButton.setImage(image, for: .normal)
    }
    
    @IBAction private func checkboxButtonAction(_ sender: UIButton) {
        enabled = !enabled
        setCheckboxButton(enabled: enabled)
        delegate?.checkboxTapped(enabled: enabled)
    }
    
}
