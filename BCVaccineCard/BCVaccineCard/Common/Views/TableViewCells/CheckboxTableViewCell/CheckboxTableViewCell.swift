//
//  CheckboxTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-01.
// TODO: If there is a screen with multiple checkboxes, then we'll need to add a type enum to distinguish

import UIKit

protocol CheckboxTableViewCellDelegate: AnyObject {
    func checkboxTapped(selected: Bool)
}

class CheckboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var checkboxButton: UIButton!
    @IBOutlet weak private var checkboxTextLabel: UILabel!
    
    private weak var delegate: CheckboxTableViewCellDelegate?
    var checkboxSelected: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        checkboxTextLabel.textColor = AppColours.textBlack
        checkboxTextLabel.font = UIFont.bcSansRegularWithSize(size: 13)
    }

    func configure(selected: Bool, text: String, delegateOwner: UIViewController) {
        checkboxTextLabel.text = text
        self.checkboxSelected = selected
        adjustImage(selected: selected)
        self.delegate = delegateOwner as? CheckboxTableViewCellDelegate
        setupAccessibility()
    }
    
    @IBAction private func checkboxButtonTapped(_ sender: UIButton) {
        checkboxSelected = !checkboxSelected
        adjustImage(selected: checkboxSelected)
        self.delegate?.checkboxTapped(selected: checkboxSelected)
        setupAccessibility()
    }
    
    private func adjustImage(selected: Bool) {
        let image = selected ? UIImage(named: "checkbox-filled") : UIImage(named: "checkbox-empty")
        checkboxButton.setImage(image, for: .normal)
    }
    
    private func setupAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = .checkBox
        self.accessibilityTraits = .button
        self.accessibilityValue = checkboxSelected ? .selected : .unselected
        if let labelText = checkboxTextLabel.text {
            self.accessibilityHint = "\(String.selectTo) \(labelText)"
        }
    }
    
    override func accessibilityActivate() -> Bool {
        checkboxButtonTapped(checkboxButton)
        return true
    }
}
