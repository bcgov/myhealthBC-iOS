//
//  CommentTextFieldView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-08-30.
//
// FIXME: NEED TO LOCALIZE 
import UIKit


protocol CommentTextFieldViewDelegate {
    func textChanged(text: String?)
    func submit(text: String)
}

class CommentTextFieldView: UIView, UITextFieldDelegate {
    
    let MAXCHAR = 1000
    
    @IBOutlet weak var fieldContainer: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var delegate: CommentTextFieldViewDelegate? = nil
    
    @IBAction func textFieldChanged(_ sender: Any) {
        delegate?.textChanged(text: textField.text)
        styleSubmit(enabled: textField.text?.count ?? 0 > 0)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        print("tapped send")
        guard let text = textField.text, text.count > 0 else {return}
        delegate?.submit(text: text)
        textField.text = ""
        styleSubmit(enabled: false)
        textField.endEditing(true)
        resignFirstResponder()
    }
    
    func setup() {
        style()
    }
    
    private func styleSubmit(enabled: Bool) {
        let img = enabled ? UIImage(named: "submit-active" ) : UIImage(named: "submit-inactive")
        submitButton.setImage(img, for: .normal)
    }
    
    private func style() {
        guard fieldContainer != nil else { return }
        messageLabel.alpha = 0
        messageLabel.font = UIFont.bcSansRegularWithSize(size: 12)
        backgroundColor = .white
        fieldContainer.backgroundColor = AppColours.backgroundGray
        fieldContainer.layer.cornerRadius = 4
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.placeholder = "Comment here"
        textField.textColor = AppColours.textGray
        textField.font = UIFont.bcSansRegularWithSize(size: 17)
        submitButton.setTitle("", for: .normal)
        submitButton.setImage(UIImage(named: "submit-inactive"), for: .normal)
        leftImageView.image = UIImage(named: "https")
        textField.delegate = self
        
        self.layer.cornerRadius = 4
//        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
//        self.layer.shadowOpacity = 1
//        self.layer.shadowOffset = CGSize(width: -1, height: 5)
//        self.layer.shadowRadius = 5
        layoutSubviews()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        let isAllowed = count <= MAXCHAR
        if !isAllowed {
            showMaxCharCount()
        } else {
            removeMaxCharCount()
        }
        return isAllowed
    }
    
    func showMaxCharCount() {
        messageLabel.alpha = 1
        messageLabel.text = "Maximum \(MAXCHAR) characters"
        messageLabel.textColor = AppColours.appRed
        fieldContainer.backgroundColor = AppColours.appRed.withAlphaComponent(0.1)
    }
    
    func removeMaxCharCount() {
        messageLabel.alpha = 0
        fieldContainer.backgroundColor = AppColours.backgroundGray
    }
    
}
