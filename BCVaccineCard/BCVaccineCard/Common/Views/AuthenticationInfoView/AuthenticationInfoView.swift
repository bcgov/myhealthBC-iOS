//
//  AuthenticationInfoView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//

import UIKit

class AuthenticationInfoView: UIView, Theme {
    
    enum Result {
        case Continue
        case Cancel
        case Back
    }
    
    @IBOutlet weak var navDivider: UIView!
    @IBOutlet weak var navBackButton: UIButton!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var completion: ((Result)->Void)?
    
    @IBAction func continueAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        completion(.Continue)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        completion(.Cancel)
    }
    
    @IBAction func backAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        completion(.Back)
    }
    
    func setup(in view: UIView, completion: @escaping (Result)->Void) {
        self.frame = .zero
        view.addSubview(self)
        self.addEqualSizeContraints(to: view)
        self.completion = completion
        style()
    }
    
    func style() {
        style(button: continueButton, style: .Fill, title: "Continue")
        style(button: cancelButton, style: .Hollow, title: .cancel)
        
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        messageLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        
        titleLabel.textColor = AppColours.appBlue
        
        titleLabel.text = "Leaving My Health BC"
        messageLabel.attributedText =
            NSMutableAttributedString()
                .normal("You will be temporarily redirected to ")
                .bold("Health Gateway ")
                .normal("to login with your BC Services Card.\n\n")
                .normal("You will then be automatically returned to the")
                .bold("My Health BC")
                .normal("mobile app.")
        navBackButton.setTitle("", for: .normal)
        
        let backIcon = UIImage(named: "app-back-arrow")?.withRenderingMode(.alwaysTemplate)
        navBackButton.setImage(backIcon, for: .normal)
        navBackButton.tintColor = AppColours.appBlue
        
        navTitle.text = "Go To Health Gateway"
        navTitle.font = UIFont.bcSansBoldWithSize(size: 17)
        navTitle.textColor = AppColours.appBlue
        navDivider.backgroundColor = .lightGray.withAlphaComponent(0.3)
    }
}