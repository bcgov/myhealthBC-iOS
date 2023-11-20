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
    @IBOutlet private weak var buttonStackView: UIStackView!
    // iPad
    @IBOutlet private weak var leftLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightLeadingTitleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightLeadingSubtitleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightLeadingInfoConstraint: NSLayoutConstraint!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: .deviceDidRotate, object: nil)
        
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
        NotificationCenter.default.post(name: .performedAuth, object: nil, userInfo: nil)
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
        adjustForiPad()
        setBaseText()
        var hasBiometric: Bool = false
        
        switch manager.biometricType {
        case .none:
            useTouchIDButton.isHidden = true
        case .touchID:
            useTouchIDButton.isHidden = false
            style(button: turnOnTouchIDButton, style: .Fill, title: .setupAuthentication, image: nil, bold: true)
            style(button: useTouchIDButton, style: .Fill, title: .useTouchId, image: nil, bold: true)
            hasBiometric = true
        case .faceID:
            useTouchIDButton.isHidden = false
            style(button: turnOnTouchIDButton, style: .Fill, title: .setupAuthentication, image: nil, bold: true)
            style(button: useTouchIDButton, style: .Fill, title: .useFaceId, image: nil, bold: true)
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
                turnOnTouchIDButton.setTitle(.setupAuthentication, for: .normal)
            }
            useTouchIDButton.isHidden = true
            usePasscodeButton.isHidden = true
            alertNotAvailable()
        }
    }
    // TODO: Adjust font here
    func setBaseText() {
        self.backgroundColor = .white
        titleLabel.text = .protectYourPersonalInformation
        subtitleLabel.text = .localAuthViewDescription
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: .learnMoreAboutLocalAuth, attributes: underlineAttribute)
        infoLabel.attributedText = underlineAttributedString
        
        style(button: turnOnTouchIDButton, style: .Fill, title: .setupAuthentication, image: nil, bold: true)
        style(button: useTouchIDButton, style: .Fill, title: .useTouchId, image: nil, bold: true)
        style(button: usePasscodeButton, style: .Fill, title: .usePassCode, image: nil, bold: true)
        
        let titleSize: CGFloat = Constants.deviceType == .iPad ? 33 : 24
        style(label: titleLabel, style: .Bold, size: titleSize, colour: .Blue)
        style(label: subtitleLabel, style: .Regular, size: 17, colour: .Grey)
        style(label: infoLabel, style: .Regular, size: 17, colour: .Blue)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPrivacy(_:)))
        infoLabel.isUserInteractionEnabled = true
        infoLabel.addGestureRecognizer(tap)
    }
    
    @objc func showPrivacy(_ sender: UITapGestureRecognizer? = nil) {
        let privacyView: LocalAuthPrivacyView = LocalAuthPrivacyView.fromNib()
        let foriPad = Constants.deviceType == .iPad
        if foriPad {
            // Show gray background here
            let grayView = UIView(frame: self.frame)
            grayView.backgroundColor = AppColours.backgroundGray
            self.addSubview(grayView)
            grayView.addEqualSizeContraints(to: self)
            
        }
        privacyView.show(over: self, foriPad: foriPad)
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

// MARK: For iPad
// 820 by 1180 on 10th gen
// 125 spacing portrait, 300 spacing landscape
extension LocalAuthView {
    private func adjustForiPad() {
        guard Constants.deviceType == .iPad else { return }
        let width = self.frame.width
        let constant: CGFloat = UIDevice.current.orientation.isLandscape ? width * 0.25 : width * 0.15
        leftLeadingConstraint.constant = constant
        rightLeadingTitleConstraint.constant = constant
        rightLeadingSubtitleConstraint.constant = constant
        rightLeadingInfoConstraint.constant = constant
        infoLabel.textAlignment = .left
        usePasscodeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        useTouchIDButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        turnOnTouchIDButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    @objc private func deviceDidRotate(_ notification: Notification) {
        adjustForiPad()
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
