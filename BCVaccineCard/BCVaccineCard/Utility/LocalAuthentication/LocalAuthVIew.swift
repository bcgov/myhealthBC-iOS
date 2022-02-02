//
//  LocalAuthVIew.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-27.
//

import Foundation
import UIKit
class LocalAuthView: UIView, Theme {
    static let viewTag = 41312
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var turnOnTouchIDButton: UIButton!
    @IBOutlet weak var useTouchIDButton: UIButton!
    @IBOutlet weak var usePasscodeButton: UIButton!
    
    // MARK: Local variables
    weak var parent: UIViewController?
    
    var manager: LocalAuthManager? = nil
    var enableTouchIdCallback: (()->Void)?
    var useTouchIdCallback: (()->Void)?
    var usePasscodeCallback: (()->Void)?
    
    enum State {
        case Success
        case Fail
        case Unavailable
    }
    
    enum ViewType {
        case Authenticate
        case EnableAuthentication
    }
    
    // MARK: Outlet Actions
    
    @IBAction func turnOnTouchID(_ sender: Any) {
        guard let enableTouchIdCallback = enableTouchIdCallback else {
            return
        }
        enableTouchIdCallback()
        
    }
    @IBAction func useTouchID(_ sender: Any) {
        guard let useTouchIdCallback = useTouchIdCallback else {
            return
        }
        useTouchIdCallback()
    }
    
    @IBAction func usePasscode(_ sender: Any) {
        guard let usePasscodeCallback = usePasscodeCallback else {
            return
        }
        usePasscodeCallback()
    }
    
    // MARK: Display
    func display(
        on viewController: UIViewController,
        type: ViewType,
        manager: LocalAuthManager,
        enableTouchId: @escaping()->Void,
        useTouchId: @escaping()->Void,
        usePasscode: @escaping()->Void
    ) {
        self.parent = viewController
        self.manager = manager
        self.usePasscodeCallback = usePasscode
        self.enableTouchIdCallback = enableTouchId
        self.useTouchIdCallback = useTouchId
        
        if let existing = viewController.view.viewWithTag(LocalAuthView.viewTag) {
            existing.removeFromSuperview()
        }
        tag = LocalAuthView.viewTag
        
        viewController.view.addSubview(self)
        addEqualSizeContraints(to: viewController.view)
        
        layoutIfNeeded()
        style(type: type)
    }
    
    func dismiss(animated: Bool) {
        if !animated {
            self.removeFromSuperview()
            return
        }
        self.isUserInteractionEnabled = false
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else {return}
            UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut) {
                [weak self] in
                guard let self = self else {return}
                self.alpha = 0
                self.layoutIfNeeded()
            } completion: { [weak self] done in
                guard let self = self else {return}
                self.removeFromSuperview()
            }
        }
    }

    // MARK: States
    func setSuccess() {
        dismiss(animated: true)
    }

    func setFail() {
        style(type: .Authenticate)
    }

    func setUnAvailable() {
        style(type: .EnableAuthentication)
    }
    
    // MARK: Style
    func style(type: ViewType) {
        guard let manager = manager else {
            return
        }
        setBaseText()
        var hasBiometric: Bool = false
        
        switch manager.biometricType {
        case .none:
            useTouchIDButton.isHidden = true
        case .touchID:
            useTouchIDButton.isHidden = false
            style(button: turnOnTouchIDButton, style: .Fill, title: "Turn on Touch ID")
            style(button: useTouchIDButton, style: .Fill, title: "Use Touch ID")
            hasBiometric = true
        case .faceID:
            useTouchIDButton.isHidden = false
            style(button: turnOnTouchIDButton, style: .Fill, title: "Turn on Face ID")
            style(button: useTouchIDButton, style: .Fill, title: "Use Face ID")
            hasBiometric = true
        @unknown default:
            useTouchIDButton.isHidden = true
        }
        
        if !manager.isBiometricAvailable {
            hasBiometric = false
        }
        
        switch type {
        case .Authenticate:
            turnOnTouchIDButton.isHidden = true
            if hasBiometric {
                usePasscodeButton.isHidden = true
                useTouchIDButton.isHidden = false
            } else {
                usePasscodeButton.isHidden = false
                useTouchIDButton.isHidden = true
            }
            
        case .EnableAuthentication:
            turnOnTouchIDButton.isHidden = false
            if !hasBiometric {
                turnOnTouchIDButton.setTitle("Turn on passcode", for: .normal)
            }
            useTouchIDButton.isHidden = true
            usePasscodeButton.isHidden = true
            alertNotAvailable()
        }
    }
    
    func setBaseText() {
        self.backgroundColor = .white
        titleLabel.text = "Protect your personal information"
        subtitleLabel.text = "Unlock My Health BC with biometric authentication is mandatory, to make sure your health information safe and secure."
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Learn more about enabling biometric on your device", attributes: underlineAttribute)
        infoLabel.attributedText = underlineAttributedString
        
        style(button: turnOnTouchIDButton, style: .Fill, title: "Turn on Touch ID")
        style(button: useTouchIDButton, style: .Fill, title: "Use Touch ID")
        style(button: usePasscodeButton, style: .Fill, title: "Use passcode")
        
        style(label: titleLabel, style: .Bold, size: 24, colour: .Blue)
        style(label: subtitleLabel, style: .Regular, size: 17, colour: .Grey)
        style(label: infoLabel, style: .Regular, size: 17, colour: .Blue)
        
    }
    
    func setState(state: LocalAuthView.State) {
        switch state {
        case .Success:
            setSuccess()
        case .Fail:
            setFail()
        case .Unavailable:
            setUnAvailable()
        }
        guard state == .Success else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            [weak self] in
            guard let self = self else {return}
            UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseOut) {
                [weak self] in
                guard let self = self else {return}
                self.alpha = 0
                self.layoutIfNeeded()
            } completion: { [weak self] done in
                guard let self = self else {return}
                if state == .Success {
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    private func alertNotAvailable() {
//        parent?.alert(title: "Unsecure device", message: "Please enable authentication on your device to proceed")
    }
}

extension UIView {
    func findTopMostVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

