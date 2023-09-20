//
//  ManageQuickLinkTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-08-01.
//

import UIKit

protocol ManageQuickLinkTableViewCellDelegate: AnyObject {
    func checkboxTapped(enabled: Bool, indexPath: IndexPath)
}

class ManageQuickLinkTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var roundedView: UIView!
    @IBOutlet private weak var quickLinkLabel: UILabel!
    @IBOutlet private weak var checkboxButton: UIButton!
    
    private weak var delegate: ManageQuickLinkTableViewCellDelegate?
    private var enabled = false
    private var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowRadius = 6.0
        
        roundedView.layer.cornerRadius = 3
        roundedView.layer.masksToBounds = true
        
        quickLinkLabel.textColor = AppColours.textBlack
        quickLinkLabel.font = UIFont.bcSansBoldWithSize(size: 15)
    }
    
    func configure(quickLink: QuickLinksPreferences, delegateOwner: UIViewController, indexPath: IndexPath) {
        self.enabled = quickLink.enabled
        self.indexPath = indexPath
        quickLinkLabel.text = quickLink.name.getManageScreenDisplayableName
        setCheckboxButton(enabled: self.enabled)
        self.delegate = delegateOwner as? ManageQuickLinkTableViewCellDelegate
    }
    
    private func setCheckboxButton(enabled: Bool) {
        let image = enabled ? UIImage(named: "quick_checkbox_filled") : UIImage(named: "quick_checkbox_empty")
        checkboxButton.setImage(image, for: .normal)
    }
    
    @IBAction private func checkboxButtonAction(_ sender: UIButton) {
        enabled = !enabled
        setCheckboxButton(enabled: enabled)
        delegate?.checkboxTapped(enabled: enabled, indexPath: self.indexPath)
    }
    
}
