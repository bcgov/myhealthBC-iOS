//
//  ForceUpdateView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-03.
//

import UIKit

class ForceUpdateView: UIView, Theme {
    
    static let tag = 921412432
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var contactLabel: UILabel!
    
    @IBOutlet weak var decLabel: UILabel!
    @IBAction func updateAction(_ sender: Any) {
    }
    
    static func show() {
        guard let window = AppDelegate.sharedInstance?.window else {
            return
        }
        if let existing = window.viewWithTag(tag) {
            existing.removeFromSuperview()
            return
        }
        let view: ForceUpdateView = ForceUpdateView.fromNib()
        view.frame = window.bounds
        window.addSubview(view)
        
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
        contactLabel.font = UIFont.bcSansRegularWithSize(size: 14)
    }
}
