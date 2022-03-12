//
//  AuthenticationView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//

import UIKit

class AuthenticationView: UIView, Theme {
    enum Result {
        case Login
        case Cancel
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var completion: ((Result)->Void)?
    
    @IBAction func loginAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        completion(.Login)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        completion(.Cancel)
    }
    
    func setup(in view: UIView, completion: @escaping (Result)->Void) {
        self.frame = .zero
        view.addSubview(self)
        self.addEqualSizeContraints(to: view)
        self.completion = completion
        style()
    }
    
    func style() {
        style(button: loginButton, style: .Fill, title: .bcscLogin, image: UIImage(named: "bcscLogo"))
        style(button: cancelButton, style: .Hollow, title: .notNow, image: nil)
        
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        subtitleLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        
        titleLabel.textColor = AppColours.appBlue
    }
}
