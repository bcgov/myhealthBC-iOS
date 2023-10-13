//
//  AuthenticationView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class AuthenticationView: UIView, Theme {
    enum Result {
        case Login
        case Cancel
    }
    
    @IBOutlet weak var downloadBCSCLabel: UILabel!
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
        downloadBCSCLabel.font = UIFont.bcSansBoldWithSize(size: 13)
        titleLabel.textColor = AppColours.appBlue
    }
    
    func fillText() {
        titleLabel.text = "Log in with your BC Services Card to access all health records"
        subtitleLabel.text = "The BC Services Card app is a secure way to prove who you are. Follow the instructions to get set up and log in."
        secondarySubtitle.text = "You can complete this step any time. If you choose to skip it for now, you'll only be able to access proof of vaccination and health resources."
        
        let fontAttribute = [NSAttributedString.Key.font: UIFont.bcSansBoldWithSize(size: 13)]
        let attributedString = NSMutableAttributedString(string:"Don’t have BC Service Card app, please download here.", attributes: fontAttribute)
        _ = attributedString.setAsLink(textToFind: "download", linkURL: Constants.BCSC.downloadURL)
        downloadBCSCLabel.attributedText = attributedString
        
        setupDownloadBCSCLabel()
    }
    
    func setupDownloadBCSCLabel() {
        if let bcscURI = URL(string: Constants.BCSC.scheme), UIApplication.shared.canOpenURL(bcscURI) {
            // App is installed, don't show download label
            downloadBCSCLabel.isHidden = true
        } else if let url = URL(string: Constants.BCSC.downloadURL), UIApplication.shared.canOpenURL(url) {
            // App is not installed and user can download, show download label
            downloadBCSCLabel.isHidden = false
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.downloadBCSC(_:)))
            downloadBCSCLabel.addGestureRecognizer(gesture)
            downloadBCSCLabel.isUserInteractionEnabled = true
        } else {
            // User doesnt have the App and can't install it
            downloadBCSCLabel.isHidden = true
        }
    }
    
    @objc func downloadBCSC(_ sender: UITapGestureRecognizer? = nil) {
        if let url = URL(string: Constants.BCSC.downloadURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
