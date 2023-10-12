//
//  ProtectiveWordPromptViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-03.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

enum ProtectiveWordPurpose: String {
    case initialFetch = "initialFetch"
    case viewingRecords = "viewingRecords"
    
    static var purposeKey: String {
        return "purpose"
    }
}

class ProtectiveWordPromptViewController: BaseViewController {
    struct ViewModel {
        var delegate: ProtectiveWordPromptDelegate
        var purpose: ProtectiveWordPurpose
    }
    
    class func construct(viewModel: ViewModel) -> ProtectiveWordPromptViewController {
        if let vc = Storyboard.reusable.instantiateViewController(withIdentifier: String(describing: ProtectiveWordPromptViewController.self)) as? ProtectiveWordPromptViewController {
            vc.viewModel = viewModel
            vc.modalPresentationStyle = .overFullScreen
            return vc
        }
        return ProtectiveWordPromptViewController()
    }
    
    @IBOutlet weak private var navHackCloseButton: UIButton!
    @IBOutlet weak private var navHackTitleLabel: UILabel!
    @IBOutlet weak private var navHackSeparatorView: UIView!
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
    
    private var viewModel: ViewModel?
    
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
        navHackTitleLabel.text = .unlockRecords
        navHackSeparatorView.backgroundColor = AppColours.borderGray
        clickableSubtitleLabel.attributedText = clickableSubtitleLabel.attributedText(withString: "Enter the protective word to access your medication history from PharmaNet. Find out more",
                                                                                      linkedStrings: [LinkedStrings(text: "more", link: "https://www2.gov.bc.ca/gov/content/health/health-drug-coverage/pharmacare-for-bc-residents/pharmanet/protective-word-for-a-pharmanet-record")],
                                                                                      textColor: AppColours.textBlack,
                                                                                      font: UIFont.bcSansRegularWithSize(size: 15))
        clickableSubtitleLabel.numberOfLines = 0
        textFieldTitle.font = UIFont.bcSansBoldWithSize(size: 17)
        textFieldTitle.textColor = AppColours.textBlack
        textFieldTitle.text = "Protective word"
        protectiveWordTextField.textColor = AppColours.textBlack
        protectiveWordTextField.placeholder = "e.g. PA6729BC"
        protectiveWordTextField.delegate = self
//        protectiveWordTextField.autocapitalizationType = .allCharacters
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
        if string == "" {
            textField.deleteBackward()
        } else {
            textField.insertText(string.uppercased())
        }
        return false
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
            guard let purpose = viewModel?.purpose else { return }
            guard let delegate = viewModel?.delegate else {return}
            dismiss(animated: true, completion: {
                delegate.protectiveWordProvided(string: proWord)
            })
            
        }
    }
    
    func shouldButtonBeEnabled(text: String?) -> Bool {
        return text?.trimWhiteSpacesAndNewLines.count ?? 0 > 0
    }
}

protocol ProtectiveWordPromptDelegate {
    func protectiveWordProvided(string: String)
}

