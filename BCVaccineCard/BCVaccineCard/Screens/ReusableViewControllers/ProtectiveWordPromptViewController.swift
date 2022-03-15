//
//  ProtectiveWordPromptViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-03.
//

import UIKit

enum ProtectiveWordPurpose: String {
    case initialFetch = "initialFetch"
    case viewingRecords = "viewingRecords"
    
    static var purposeKey: String {
        return "purpose"
    }
}

class ProtectiveWordPromptViewController: BaseViewController {
    
    class func constructProtectiveWordPromptViewController(purpose: ProtectiveWordPurpose) -> ProtectiveWordPromptViewController {
        if let vc = Storyboard.reusable.instantiateViewController(withIdentifier: String(describing: ProtectiveWordPromptViewController.self)) as? ProtectiveWordPromptViewController {
            vc.purpose = purpose
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
        return ProtectiveWordPromptViewController()
    }
    
    @IBOutlet weak private var navHackCloseButton: UIButton!
    @IBOutlet weak private var navHackTitleLabel: UILabel!
    @IBOutlet weak private var navHackSeparatorView: UIView!
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
    
    private var purpose: ProtectiveWordPurpose?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
        navHackCloseButton.setImage(UIImage(named: "close-icon-blue"), for: .normal)
        navHackCloseButton.tintColor = AppColours.appBlue
        navHackTitleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
        navHackTitleLabel.textColor = AppColours.appBlue
        navHackTitleLabel.text = .protectedWordVCNavTitle
        navHackSeparatorView.backgroundColor = AppColours.borderGray
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 20)
        titleLabel.textColor = AppColours.textBlack
        titleLabel.text = "View your medication records"
        clickableSubtitleLabel.attributedText = clickableSubtitleLabel.attributedText(withString: "Please enter the protective word required to access these restricted PharmaNet records. For more information visit protective-word-for-a-pharmanet-record",
                                                                                      linkedStrings: [LinkedStrings(text: "protective-word-for-a-pharmanet-record", link: "https://www2.gov.bc.ca/gov/content/health/health-drug-coverage/pharmacare-for-bc-residents/pharmanet/protective-word-for-a-pharmanet-record")],
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
    
    @IBAction private func navHackCloseButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: For Button tap and enabling
extension ProtectiveWordPromptViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            self.dismiss(animated: true, completion: nil)
        } else if type == .continueType {
            guard let proWord = protectiveWordTextField.text else { return }
            guard let purpose = self.purpose else { return }
            let userInfo: [String: String] = [
                Constants.AuthenticatedMedicationStatementParameters.protectiveWord : proWord,
                ProtectiveWordPurpose.purposeKey: purpose.rawValue]
            NotificationCenter.default.post(name: .protectedWordProvided, object: nil, userInfo: userInfo)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func shouldButtonBeEnabled(text: String?) -> Bool {
        return text?.trimWhiteSpacesAndNewLines.count ?? 0 > 0
    }

}

