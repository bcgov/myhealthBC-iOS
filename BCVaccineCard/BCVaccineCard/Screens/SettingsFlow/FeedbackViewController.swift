//
//  FeedbackViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-03-23.
//

import UIKit

// TODO: Tinker with the UI
    // - Dismiss keyboard logic
    // - Spacing/margins for text view
    // - Potentially a growing/expanding text view
    // - Placeholder text logic needs some work

class FeedbackViewController: BaseViewController {
    
    class func construct() -> FeedbackViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: FeedbackViewController.self)) as? FeedbackViewController {
            return vc
        }
        return FeedbackViewController()
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var feedbackTextView: UITextView!
    @IBOutlet private var placeholderLabel: UILabel!
    @IBOutlet private var characterCountLabel: UILabel!
    @IBOutlet private var characterWarningMessageLabel: UILabel!
    @IBOutlet private var sendMessageButton: AppStyleButton!
    
    private let characterLimit = 500
    private let placeholderText = "Describe your suggestion or idea..."

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navSetup()
        labelSetup()
        setupTextView()
        setupButton()
    }

}

// MARK: Nav setup
extension FeedbackViewController {
    
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: "Feedback",
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

// MARK: Label setup
extension FeedbackViewController {
    
    private func labelSetup() {
        titleLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        titleLabel.textColor = AppColours.textBlack
        titleLabel.text = "Do you have a suggestion or idea? Let us know in the field below"
        
        characterCountLabel.text = "0/\(characterLimit)"
        characterCountLabel.textColor = AppColours.textGray
        characterCountLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        
        characterWarningMessageLabel.textColor = AppColours.appRed
        characterWarningMessageLabel.text = "Maximum 500 characters"
        characterWarningMessageLabel.font = UIFont.bcSansRegularWithSize(size: 13)
        characterWarningMessageLabel.isHidden = true
        
        placeholderLabel.text = placeholderText
        placeholderLabel.textColor = AppColours.textGray
        placeholderLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        placeholderLabel.isUserInteractionEnabled = false
    }
}

// MARK: TextView setup
extension FeedbackViewController: UITextViewDelegate {
    
    private func setupTextView() {
        feedbackTextView.delegate = self
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.textColor = AppColours.textGray
        feedbackTextView.font = UIFont.bcSansRegularWithSize(size: 17)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // Format other UI
        formatUI(underLimit: updatedText.count < characterLimit, characterCount: currentText.count)

        // make sure the result is under 500 characters
        return updatedText.count <= characterLimit
    }
    
    private func formatUI(underLimit: Bool, characterCount: Int) {
        formatTextView(underLimit: underLimit)
        formatLabel(underLimit: underLimit, characterCount: characterCount)
        updateButtonStatus(underLimit: underLimit, characterCount: characterCount)
    }
    
    private func formatTextView(underLimit: Bool) {
        feedbackTextView.layer.borderColor = underLimit ? AppColours.textGray.cgColor : AppColours.appRed.cgColor
    }
    
    private func formatLabel(underLimit: Bool, characterCount: Int) {
        characterWarningMessageLabel.isHidden = underLimit
        characterCountLabel.text = "\(characterCount)/\(characterLimit)"
        characterCountLabel.textColor = underLimit ? AppColours.textGray : AppColours.appRed
        placeholderLabel.isHidden = characterCount > 0
    }
    
    private func updateButtonStatus(underLimit: Bool, characterCount: Int) {
        sendMessageButton.enabled = underLimit && characterCount > 0
    }
    
}

// MARK: Setup button
extension FeedbackViewController: AppStyleButtonDelegate {

    private func setupButton() {
        sendMessageButton.configure(withStyle: .blue, buttonType: .sendMessage, delegateOwner: self, enabled: false)
    }
    
    func buttonTapped(type: AppStyleButton.ButtonType) {
        guard type == .sendMessage else { return }
        // TODO: Functionality done here for making the network request
    }
}
