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
    @IBOutlet weak var secondarySubtitle: UILabel!
    
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
        fillText()
    }
    
    func style() {
        style(button: loginButton, style: .Fill, title: .bcscLogin, image: nil, bold: true)
        style(button: cancelButton, style: .Hollow, title: .notNow, image: nil, bold: true)
        
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        subtitleLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        secondarySubtitle.font = UIFont.bcSansRegularWithSize(size: 13)
        
        titleLabel.textColor = AppColours.appBlue
    }
    
    func fillText() {
        titleLabel.text = "Log in with your BC Services Card to access all health records"
        subtitleLabel.text = "The BC Services Card app is a secure way to prove who you are. Follow the instructions to get set up and log in."
        secondarySubtitle.text = "You can complete this step any time. If you choose to skip it for now, you'll only be able to access proof of vaccination and health resources."
        
    }
}
