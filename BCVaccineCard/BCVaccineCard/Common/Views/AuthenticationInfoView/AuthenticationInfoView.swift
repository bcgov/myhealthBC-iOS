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
    @IBOutlet weak private var buttonsStackView: UIStackView!
    @IBOutlet weak private var textImageParentStackView: UIStackView!
    @IBOutlet weak private var textStackView: UIStackView!
    @IBOutlet weak private var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var buttonStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var imageViewWidthConstraint: NSLayoutConstraint!
    
    private var completion: ((Result)->Void)?
    private var parentVC: UIViewController?
    
    @IBAction func continueAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        continueButton.isUserInteractionEnabled = false
        completion(.Continue)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        continueButton.isUserInteractionEnabled = false
        completion(.Cancel)
    }
    
    @IBAction func backAction(_ sender: Any) {
        guard let completion = self.completion else {return}
        completion(.Back)
    }
    
    func setup(in view: UIView, parentVC: UIViewController, completion: @escaping (Result)->Void) {
        self.frame = .zero
        view.addSubview(self)
        self.addEqualSizeContraints(to: view)
        self.parentVC = parentVC
        self.completion = completion
        style()
        setupAccessibility()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: .deviceDidRotate, object: nil)
        iPadUIAdjustments()
    }
    
    func style() {
        style(button: continueButton, style: .Fill, title: .continueText, image: nil, bold: true)
        style(button: cancelButton, style: .Hollow, title: .cancel, image: nil, bold: true)
        
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 24)
        messageLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        
        titleLabel.textColor = AppColours.appBlue
        
        titleLabel.text = .leavingHealthGateway
        messageLabel.attributedText =
            NSMutableAttributedString()
            .normal(.youWillRedirected)
            .normal("\(String.toLoginWithYourBCServices)\n\n")
            .normal(.youWillAutomaticallyReturned)
            .normal(.healthGateway)
        navBackButton.setTitle("", for: .normal)
        
        let backIcon = UIImage(named: "app-back-arrow")?.withRenderingMode(.alwaysTemplate)
        navBackButton.setImage(backIcon, for: .normal)
        navBackButton.tintColor = AppColours.appBlue
        
        navTitle.text = .bcServicesCard
        navTitle.font = UIFont.bcSansBoldWithSize(size: 17)
        navTitle.textColor = AppColours.appBlue
        navDivider.backgroundColor = .lightGray.withAlphaComponent(0.3)
    }
    
    private func iPadUIAdjustments() {
        // Image and Text
        textImageParentStackView.removeArrangedSubview(titleLabel)
        textStackView.removeArrangedSubview(messageLabel)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(messageLabel)
        textStackView.alignment = .leading
        imageViewWidthConstraint.constant = 60
        navDivider.isHidden = true
        navTitle.isHidden = true
        navBackButton.isHidden = true

        adjustUIForIPadOrientationChange()
    }
    
    func setupAccessibility() {
        navBackButton.accessibilityLabel = AccessibilityLabels.Navigation.backButtonTitle
        navTitle.accessibilityTraits = .header
    }
    
    // Note: This is to be called when the view transitions during rotation
    private func adjustUIForIPadOrientationChange() {
        guard Constants.deviceType == .iPad, let parentVC = self.parentVC else { return }
        let isLandscape = Constants.isIpadLandscape(vc: parentVC)
        stackViewLeadingConstraint.constant = isLandscape ? 300 : 100
        stackViewTrailingConstraint.constant = isLandscape ? 300 : 100
        if isLandscape {
            buttonsStackView.removeArrangedSubview(continueButton)
            buttonsStackView.addArrangedSubview(continueButton)
        } else {
            buttonsStackView.removeArrangedSubview(cancelButton)
            buttonsStackView.addArrangedSubview(cancelButton)
        }
        buttonsStackView.axis = isLandscape ? .horizontal : .vertical
        buttonsStackView.distribution = isLandscape ? .fill : .fillEqually
        buttonsStackView.spacing = isLandscape ? 22 : 10
        buttonStackViewBottomConstraint.constant = isLandscape ? 144 : 330
        self.layoutIfNeeded()
    }
    
    @objc private func deviceDidRotate(_ notification: Notification) {
        adjustUIForIPadOrientationChange()
    }
}
