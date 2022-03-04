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
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
        return ProtectiveWordPromptViewController()
    }
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var clickableSubtitleLabel: InteractiveLinkLabel!
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
//        self.tabBarController?.tabBar.isHidden = true
        navSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Note - sometimes tabBarController will be nil due to when it's released in memory
//        self.tabBarController?.tabBar.isHidden = false
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
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 20)
        titleLabel.textColor = AppColours.textBlack
        titleLabel.text = "View your medication records"
        clickableSubtitleLabel.attributedText = clickableSubtitleLabel.attributedText(withString: "Please enter the protective word required to access these restricted PharmaNet records. For more information visit protective-word-for-a-pharmanet-record",
                                                                                      linkedStrings: [LinkedStrings(text: "protective-word-for-a-pharmanet-record", link: "http://www.IHaveNoIdeaWhatGoesHere.com")],
                                                                                      textColor: AppColours.textBlack,
                                                                                      font: UIFont.bcSansRegularWithSize(size: 15))
        clickableSubtitleLabel.numberOfLines = 0
        textFieldTitle.font = UIFont.bcSansBoldWithSize(size: 17)
        textFieldTitle.textColor = AppColours.textBlack
        textFieldTitle.text = "Protective Word"
        protectiveWordTextField.textColor = AppColours.textBlack
        protectiveWordTextField.delegate = self
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

// MARK: For entering protective word in text field
extension ProtectiveWordPromptViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            continueButtonEnabled = shouldButtonBeEnabled(text: updatedText)
        }
        return true
    }
}

// MARK: For Button tap and enabling
extension ProtectiveWordPromptViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.navigationController?.popViewController(animated: true)
        } else if type == .continueType {
            guard let proWord = protectiveWordTextField.text else { return }
            let protectedWordDictionary: [String: String] = [Constants.AuthenticatedMedicationStatementParameters.protectiveWord : proWord]
            NotificationCenter.default.post(name: .protectedWordProvided, object: nil, userInfo: protectedWordDictionary)
        }
    }
    
    func shouldButtonBeEnabled(text: String?) -> Bool {
        return text?.trimWhiteSpacesAndNewLines.count ?? 0 > 0
    }

}

