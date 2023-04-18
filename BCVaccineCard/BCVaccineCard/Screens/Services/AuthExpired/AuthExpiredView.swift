//
//  AuthExpiredView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-04-10.
//

import UIKit

class AuthExpiredView: UIView, Theme {

    @IBOutlet weak var rectContainer: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: AuthViewDelegate?
    var contentType: ContentType?

    @IBAction func loginAction(_ sender: Any) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.authenticate(initialView: .Auth)
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
        style(button: loginButton, style: .Fill, title: "Log in with BC Services Card", image: nil, bold: true)
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        titleLabel.textColor = AppColours.appBlue
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.text = contentType?.subtitleText ?? ""
        titleLabel.text = contentType?.titleText ?? ""
        rectContainer.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
        rectContainer.layer.cornerRadius = 4
    }

}

extension AuthExpiredView {
    enum ContentType {
        case Services
        
        var titleText: String {
            return "Your session has timed out"
        }
        
        var subtitleText: String {
            switch self {
            case .Services:
                return "Log in again to view your services."
            }
        }
    }
}

