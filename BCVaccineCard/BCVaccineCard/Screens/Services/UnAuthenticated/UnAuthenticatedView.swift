//
//  AunAuthenticatedView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-04-10.
//

import UIKit

protocol AuthViewDelegate {
    func authenticate(initialView: AuthenticationViewController.InitialView)
}

class UnAuthenticatedView: UIView, Theme {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var descriptiveText: UILabel!
    
    var delegate: AuthViewDelegate?
    var contentType: ContentType?

    @IBAction func loginAction(_ sender: Any) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.authenticate(initialView: .Landing)
    }
    
    func setup(in container: UIView, type: ContentType, delegate: AuthViewDelegate) {
        container.subviews.forEach({$0.removeFromSuperview()})
        container.addSubview(self)
        self.addEqualSizeContraints(to: container)
        self.delegate = delegate
        self.contentType = type
        style()
    }
    
    func style() {
        style(button: loginButton)
        descriptiveText.font = UIFont.bcSansBoldWithSize(size: 15)
        descriptiveText.textColor = AppColours.greyText
        
        descriptiveText.text = contentType?.text ?? ""
        iconImageView.image = contentType?.graphic
    }
    
    func style(button: UIButton) {
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 18)
        button.backgroundColor = AppColours.appBlue
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.setTitle("Log in with BC Services Card", for: .normal)
    }
}

extension UnAuthenticatedView {
    enum ContentType {
        case Services
        
        var text: String {
            switch self {
            case .Services:
                return "The BC Services Card app is a secure way to prove who you are."
            }
        }
        
        var graphic: UIImage? {
            switch self {
            case .Services:
                return UIImage(named: "services-graphic")
            }
        }
    }
}
