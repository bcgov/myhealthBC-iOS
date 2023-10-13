//
//  QuickAccessCollectionReusableView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-13.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

protocol QuickAccessCollectionReusableViewDelegate: AnyObject {
    func manageButtonTapped()
}

class QuickAccessCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet private weak var quickAccessLabel: UILabel!
    @IBOutlet private weak var manageButton: UIButton!
    
    weak private var delegate: QuickAccessCollectionReusableViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        quickAccessLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        quickAccessLabel.textColor = AppColours.appBlue
        quickAccessLabel.text = "Quick access"
        manageButton.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 13)
        manageButton.setTitleColor(AppColours.blueLightText, for: .normal)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppColours.blueLightText,
            .font: UIFont.bcSansBoldWithSize(size: 13),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: AppColours.blueLightText
        ]
        let attrStr = NSAttributedString(string: "Manage", attributes: attributes)
        manageButton.setAttributedTitle(attrStr, for: .normal)
    }
    
    func configure(status: AuthStatus, delegateOwner: UIViewController) {
        manageButton.isHidden = status == .UnAuthenticated
        self.delegate = delegateOwner as? QuickAccessCollectionReusableViewDelegate
    }
    
    @IBAction private func manageButtonTapped(_ sender: UIButton) {
        self.delegate?.manageButtonTapped()
    }
    
}
