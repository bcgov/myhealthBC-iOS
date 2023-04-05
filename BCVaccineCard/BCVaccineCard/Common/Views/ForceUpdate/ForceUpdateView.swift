//
//  ForceUpdateView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-03.
//

import UIKit

protocol ForceUpdateViewDelegate {
    func openStoreAppStore()
}

class ForceUpdateView: UIView, Theme {
    
    static let tag = 921412432
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var decLabel: UILabel!
    
    var delegate: ForceUpdateViewDelegate?
    
    static func show(delegate: ForceUpdateViewDelegate, tabBarController: AppTabBarController) {
        if let existing = tabBarController.view.viewWithTag(tag) {
            existing.removeFromSuperview()
        }
        let view: ForceUpdateView = ForceUpdateView.fromNib()
        view.frame = tabBarController.view.bounds
        tabBarController.view.addSubview(view)
        view.addEqualSizeContraints(to: tabBarController.view)
        view.delegate = delegate
        view.style()
    }
    
    func style() {
        tag = ForceUpdateView.tag
        backgroundColor = AppColours.appBlue
        titleLabel.textColor = .white
        decLabel.textColor = .white
        contactLabel.textColor = .white
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        decLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        style(button: updateButton,
              style: .Fill,
              title: "Update Now",
              image: nil,
              fillColour: .white,
              fillTitleColour: AppColours.appBlue,
              bold: true)
        contactLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        updateButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        delegate?.openStoreAppStore()
    }
    
}
