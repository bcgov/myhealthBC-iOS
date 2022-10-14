//
//  AddDependentViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-13.
//

import UIKit

struct AddDependentFormData {
    var givenName: String?
    var lastName: String?
    var dateOfBirth: Date?
    var phn: Int?
    
    var hasAgreed: Bool = false
    
    var isValid: Bool {
        return givenName != nil &&  lastName != nil && dateOfBirth != nil && phn != nil && hasAgreed
    }
}

class AddDependentViewController: UIViewController, UITextFieldDelegate {
    
    class func constructAddDependentViewController() -> AddDependentViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: AddDependentViewController.self)) as? AddDependentViewController {
            return vc
        }
        return AddDependentViewController()
    }
    
    private var formData = AddDependentFormData()
    
    @IBOutlet weak var givenNameHeader: UILabel!
    @IBOutlet weak var givenNameField: UITextField!
    @IBOutlet weak var lastNameHeader: UILabel!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var dateOfBirthHeader: UILabel!
    @IBOutlet weak var dateOfBirthField: UITextField!
    @IBOutlet weak var phnHeader: UILabel!
    @IBOutlet weak var phnField: UITextField!
    @IBOutlet weak var phnHelpText: UILabel!
    
    @IBOutlet weak var agreementBox: UIImageView!
    @IBOutlet weak var agreementLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone.current
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }()
    
    private var headers: [UILabel] {
        return [givenNameHeader, lastNameHeader, dateOfBirthHeader, phnHeader]
    }
    
    private var fields: [UITextField] {
        return [givenNameField, lastNameField, dateOfBirthField, phnField]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        style()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRegister(_ sender: Any) {
        guard formData.isValid else {return}
        // TODO: Fetch dependent data using formData
    }
    
    @objc func tappedAgreementBox(_ sender: UITapGestureRecognizer? = nil) {
        formData.hasAgreed = !formData.hasAgreed
        styleAgreementBox()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateOfBirthField.text = dateFormatter.string(from: sender.date)
        formData.dateOfBirth = sender.date
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case givenNameField:
            formData.givenName = textField.text
        case lastNameField:
            formData.lastName = textField.text
        case dateOfBirthField:
            break
        case phnField:
            if let text = textField.text, let number = Int(text) {
                formData.phn = number
            } else {
                formData.phn = nil
            }
        default:
            break
        }
        updateregisterButtonStyle()
    }
    
    func style() {
        fields.forEach({style(field: $0)})
        headers.forEach({style(header: $0)})
        // Date of Birth
        dateOfBirthField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        // Buttons
        style(buton: cancelButton, filled: false)
        style(buton: registerButton, filled: true)
        registerButton.isEnabled = false
        
        // Agreement box
        agreementBox.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedAgreementBox(_:)))
        agreementBox.addGestureRecognizer(tap)
        styleAgreementBox()
    }
    
    func style(header label: UILabel) {
        label.font = UIFont.bcSansBoldWithSize(size: 17)
    }
    
    func style(field: UITextField) {
        field.font = UIFont.bcSansRegularWithSize(size: 17)
        field.delegate = self
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func style(buton: UIButton, filled: Bool) {
        
    }
    
    func updateregisterButtonStyle() {
        registerButton.isEnabled = formData.isValid
    }
    
    func styleAgreementBox() {
        if formData.hasAgreed {
            agreementBox.image = UIImage(named: "checkbox-filled")
        } else {
            agreementBox.image = UIImage(named: "checkbox-empty")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phnField {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}
