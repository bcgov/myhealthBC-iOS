//
//  ViewController.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

class GatewayFormViewController: UIViewController {
    
    class func constructGatewayFormViewController() -> GatewayFormViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: "GatewayFormViewController") as? GatewayFormViewController {
            return vc
        }
        return GatewayFormViewController()
    }
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var phnTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var dateOfVaxTextField: UITextField!
    @IBOutlet weak var privacyStatementLabelPlaceholder: UILabel!
    @IBOutlet weak var cancelButton: AppStyleButton!
    @IBOutlet weak var enterButton: AppStyleButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        scrollView.layoutSubviews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setup() {
        containerUISetup()
        textFieldSetup()
        setupButtons()
    }
    
    private func setupButtons() {
        cancelButton.configure(withStyle: .white, buttonType: .cancel, delegateOwner: self, enabled: true)
        enterButton.configure(withStyle: .blue, buttonType: .enter, delegateOwner: self, enabled: false)
    }

    private func containerUISetup() {
        shadowContainerView.backgroundColor = .clear
        roundedContainerView.backgroundColor = .white
        // shadow
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowContainerView.layer.shadowOpacity = 0.1
        shadowContainerView.layer.shadowRadius = 10.0
        // corner radius
        roundedContainerView.layer.cornerRadius = 5
        roundedContainerView.layer.masksToBounds = true
    }
    
    private func textFieldSetup() {
        phnTextField.delegate = self
        dobTextField.delegate = self
        dateOfVaxTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }

}

// MARK: For UITextFieldDelegate
extension GatewayFormViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: String = currentString.replacingCharacters(in: range, with: string) as String
        let validated = textFieldValidation(textField: textField, newString: newString)
        enterButton.enabled = validated
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case phnTextField: dobTextField.becomeFirstResponder()
        case dobTextField: dateOfVaxTextField.becomeFirstResponder()
        default: textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldValidation(textField: UITextField, newString: String) -> Bool {
        let validated = newString.count > 0
        switch textField {
        case phnTextField:
            return (dobTextField.text?.count ?? 0 > 0) && (dateOfVaxTextField.text?.count ?? 0 > 0) && validated
        case dobTextField:
            return (phnTextField.text?.count ?? 0 > 0) && (dateOfVaxTextField.text?.count ?? 0 > 0) && validated
        case dateOfVaxTextField:
            return (phnTextField.text?.count ?? 0 > 0) && (dobTextField.text?.count ?? 0 > 0) && validated
        default: return false
        }
    }
}

// MARK: QR Vaccine Validation check
extension GatewayFormViewController {
    func checkForPHN(phnString: String) {
        var vaccinePassportModel: VaccinePassportModel
        let phn = phnString.trimWhiteSpacesAndNewLines
        let name: String
        let imageName: String
        
        var status: VaccineStatus
        if phn == "1111111111" {
            status = .fully
            name = "WILLIE BEAMEN"
            imageName = "full"
        } else if phn == "2222222222" {
            status = .partially
            name = "RON BERGUNDY"
            imageName = "partial"
        } else {
            status = .notVaxed
            name = "BRICK TAMLAND"
            imageName = ""
        }
        vaccinePassportModel = VaccinePassportModel(imageName: imageName, phn: phn, name: name, status: status)
        let vc = VaccinePassportVC.constructVaccinePassportVC(withModel: vaccinePassportModel, delegateOwner: self)
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: To go to cards tab
extension GatewayFormViewController: GoToCardsDelegate {
    func goToCardsTab() {
        self.tabBarController?.selectedIndex = 1
    }
}

// MARK: Cancel button logic
extension GatewayFormViewController {
    func clearTextFields() {
        phnTextField.text = ""
        dobTextField.text = ""
        dateOfVaxTextField.text = ""
    }
}

// MARK: For Button tap events
extension GatewayFormViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .cancel {
            clearTextFields()
        } else if type == .enter {
            checkForPHN(phnString: self.phnTextField.text ?? "")
        }
    }
}

