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
    @IBOutlet weak private var textAndImageStackView: UIStackView!
    @IBOutlet weak private var textStackView: UIStackView!
    @IBOutlet weak private var imageStackView: UIStackView!
    @IBOutlet weak private var buttonsStackView: UIStackView!
    @IBOutlet weak private var stackViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak private var stackViewLeadingSpaceConstraint: NSLayoutConstraint!
   
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: .deviceDidRotate, object: nil)
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
    
    // TODO: Make this conditional based on iPad or iPhone
    func fillText() {
        if Constants.deviceType == .iPad {
            titleLabel.text = "Log in with your BC Services Card to access all health records"
            subtitleLabel.text = "The BC Services Card app is a secure way to prove who you are. Follow the instructions to get set up and log in.\n\nYou can complete this step any time. If you choose to skip it for now, you'll only be able to access proof of vaccination and health resources."
            secondarySubtitle.isHidden = true
            iPadUIAdjustments()
        } else {
            titleLabel.text = "Log in with your BC Services Card to access all health records"
            subtitleLabel.text = "The BC Services Card app is a secure way to prove who you are. Follow the instructions to get set up and log in."
            secondarySubtitle.text = "You can complete this step any time. If you choose to skip it for now, you'll only be able to access proof of vaccination and health resources."
        }
        
        
        let fontAttribute = [NSAttributedString.Key.font: UIFont.bcSansBoldWithSize(size: 13)]
        let attributedString = NSMutableAttributedString(string:"Don’t have BC Service Card app, please download here.", attributes: fontAttribute)
        _ = attributedString.setAsLink(textToFind: "download", linkURL: Constants.BCSC.downloadURL)
        downloadBCSCLabel.attributedText = attributedString
        
        setupDownloadBCSCLabel()
    }
    
    private func iPadUIAdjustments() {
        // Image and Text
        imageStackView.removeArrangedSubview(secondarySubtitle)
        textStackView.alignment = .leading
        textAndImageStackView.removeArrangedSubview(textStackView)
        textAndImageStackView.addArrangedSubview(textStackView)
        textAndImageStackView.axis = .horizontal
        textAndImageStackView.alignment = .top
        textAndImageStackView.distribution = .fill
        textAndImageStackView.spacing = 12
        
//        stackViewTrailingSpaceConstraint.constant = UIDevice.current.orientation.isLandscape ? 300 : 150
//        stackViewLeadingSpaceConstraint.constant = UIDevice.current.orientation.isLandscape ? 300 : 150
        
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        buttonsStackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
//        buttonsStackView.distribution = UIDevice.current.orientation.isLandscape ? .fill : .fillEqually
        adjustUIForIPadOrientationChange()
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
    
    // Note: This is to be called when the view transitions during rotation
    private func adjustUIForIPadOrientationChange() {
        guard Constants.deviceType == .iPad else { return }
        stackViewTrailingSpaceConstraint.constant = UIDevice.current.orientation.isLandscape ? 200 : 90
        stackViewLeadingSpaceConstraint.constant = UIDevice.current.orientation.isLandscape ? 200 : 90
        if UIDevice.current.orientation.isLandscape {
            buttonsStackView.removeArrangedSubview(loginButton)
            buttonsStackView.addArrangedSubview(loginButton)
        } else {
            buttonsStackView.removeArrangedSubview(cancelButton)
            buttonsStackView.addArrangedSubview(cancelButton)
        }
        buttonsStackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        buttonsStackView.distribution = UIDevice.current.orientation.isLandscape ? .fill : .fillEqually
        buttonsStackView.spacing = UIDevice.current.orientation.isLandscape ? 22 : 10
        self.layoutIfNeeded()
    }
    
    @objc private func deviceDidRotate(_ notification: Notification) {
        adjustUIForIPadOrientationChange()
    }
}
