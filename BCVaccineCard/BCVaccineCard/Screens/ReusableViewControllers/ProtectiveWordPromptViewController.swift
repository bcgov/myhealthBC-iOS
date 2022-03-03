//
//  ProtectiveWordPromptViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-03.
//

import UIKit

class ProtectiveWordPromptViewController: BaseViewController {
    
    class func constructProtectiveWordPromptViewController() -> ProtectiveWordPromptViewController {
        if let vc = Storyboard.reusable.instantiateViewController(withIdentifier: String(describing: ProtectiveWordPromptViewController.self)) as? ProtectiveWordPromptViewController {
            return vc
        }
        return ProtectiveWordPromptViewController()
    }
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UITextView!
    @IBOutlet weak private var textFieldTitle: UILabel!
    @IBOutlet weak private var protectiveWordTextField: UITextField!
    @IBOutlet weak private var continueButton: AppStyleButton!
    @IBOutlet weak private var cancelButton: AppStyleButton!
    
    private var continueButtonEnabled: Bool = false {
        didSet {
            continueButton.enabled = continueButtonEnabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Putting this here in case user goes to help screen
        self.tabBarController?.tabBar.isHidden = true
        navSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Note - sometimes tabBarController will be nil due to when it's released in memory
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        uiSetup()
        setupButtons()
    }
    
    private func uiSetup() {
        // TODO: setup labels etc here
    }
    
    private func setupButtons() {
        continueButton.configure(withStyle: .blue, buttonType: .continueType, delegateOwner: self, enabled: false)
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
    }
}

// MARK: Navigation setup
extension ProtectiveWordPromptViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .protectedWordVCNavTitle,
                                               leftNavButton: NavButton(image: UIImage(named: "close-icon-blue"), action: #selector(self.closeIconButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ProtectiveWordScreen.navLeftIconTitle, hint: AccessibilityLabels.ProtectiveWordScreen.navLeftIconHint)),
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc private func closeIconButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: For Button tap and enabling
extension ProtectiveWordPromptViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.navigationController?.popViewController(animated: true)
        } else if type == .continueType {
            // TODO: Completion handler here
        }
    }
    
    func shouldButtonBeEnabled() -> Bool {
        return protectiveWordTextField.text?.trimWhiteSpacesAndNewLines.count ?? 0 > 0
    }

}

