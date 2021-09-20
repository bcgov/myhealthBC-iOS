//
//  FormTextFieldView.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-17.
//

import UIKit
// TODO: Need to set minimum and maximum dates for date picker
enum FormTextFieldKeyboardStyle {
    case number, date
}

enum FormTextFieldType {
    case personalHealthNumber, dateOfBirth, dateOfVaccination
    
    var getFieldTitle: String {
        switch self {
        case .personalHealthNumber: return Constants.Strings.MyCardFlow.Form.personalHealthNumber
        case .dateOfBirth: return Constants.Strings.MyCardFlow.Form.dateOfBirth
        case .dateOfVaccination: return Constants.Strings.MyCardFlow.Form.dateOfVaccine
        }
    }
    
    var getPlaceholderText: String {
        switch self {
        case .personalHealthNumber: return "973 7364 347"
        case .dateOfBirth: return "1967-01-21"
        case .dateOfVaccination: return "2021-01-02"
        }
    }
    
    var getImage: UIImage? {
        switch self {
        case .personalHealthNumber: return nil
        case .dateOfBirth: return #imageLiteral(resourceName: "calendar-icon")
        case .dateOfVaccination: return #imageLiteral(resourceName: "calendar-icon")
        }
    }
    
    var getFieldType: FormTextFieldKeyboardStyle {
        switch self {
        case .personalHealthNumber: return .number
        case .dateOfBirth: return .date
        case .dateOfVaccination: return .date
        }
    }
}

protocol FormTextFieldViewDelegate: AnyObject {
    func didFinishEditing(formField: FormTextFieldType, text: String?)
    func textFieldTextDidChange(formField: FormTextFieldType, newText: String)
    func resignFirstResponderUI(formField: FormTextFieldType)
    func goToNextFormTextField(formField: FormTextFieldType)
}

class FormTextFieldView: UIView {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var formTextFieldTitleLabel: UILabel!
    @IBOutlet weak private var formTextField: UITextField!
    @IBOutlet weak private var formTextFieldErrorLabel: UILabel!
    @IBOutlet weak private var formTextFieldRightImageView: UIImageView!
    
    weak var delegate: FormTextFieldViewDelegate?
    private var formField: FormTextFieldType!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("FormTextFieldView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        setupUI()
        baseSetup()
    }
    
    private func setupUI() {
        // TODO: Setup label fonts and colors here
        formTextField.textColor = AppColours.textBlack
        formTextFieldTitleLabel.textColor = AppColours.textBlack
        formTextFieldErrorLabel.textColor = AppColours.appRed
    }
    
    private func baseSetup() {
        formTextFieldErrorLabel.isHidden = true
    }
    
    func configure(formType: FormTextFieldType, delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? FormTextFieldViewDelegate
        self.formField = formType
        formTextFieldRightImageView.isHidden = formType.getFieldType == .number
        formTextFieldTitleLabel.text = formType.getFieldTitle
        formTextField.placeholder = formType.getPlaceholderText
        if let image = formType.getImage {
            formTextFieldRightImageView.image = image
        }
        createKeyboardForType(type: formType.getFieldType)
        formTextField.delegate = self
    }
    
    // This is called from didSelectRow to open the keyboard
    func openKeyboardAction() {
        self.formTextField.becomeFirstResponder()
    }
    
}

// MARK: Date picker logic
extension FormTextFieldView {
    
    private func createKeyboardForType(type: FormTextFieldKeyboardStyle) {
        switch type {
        case .number:
            formTextField.keyboardType = .numberPad
            createKeyboardToolbar() // Need to test this, may need to delete
        case .date:
            let datePicker = UIDatePicker()
            createDatePicker(datePicker: datePicker)
        }
    }
    
    private func createKeyboardToolbar() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button 'done'
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        // bar button 'next
        let nextButton = UIBarButtonItem(title: Constants.Strings.MyCardFlow.Form.nextText, style: .done, target: self, action: #selector(nextButtonTapped))
        
        // add buttons to toolbar
        toolbar.setItems([doneButton, nextButton], animated: true)
        
        // assign toolbar
        formTextField.inputAccessoryView = toolbar
    }
    
    private func createDatePicker(datePicker: UIDatePicker) {
        createKeyboardToolbar()
        
        // assign date picker to text field
        formTextField.inputView = datePicker
        
        // date picker mode
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
    }
    
    @objc func doneButtonTapped() {
        delegate?.resignFirstResponderUI(formField: self.formField)
    }
    
    @objc func nextButtonTapped() {
        delegate?.goToNextFormTextField(formField: self.formField)
    }
    
    @objc func datePickerChanged(datePicker: UIDatePicker) {
        adjustTextFieldWithDatePickerSpin(datePicker: datePicker)
    }

    private func adjustTextFieldWithDatePickerSpin(datePicker: UIDatePicker) {
        let text = Date.Formatter.longDate.string(from: datePicker.date)
        self.formTextField.text = text
        self.delegate?.textFieldTextDidChange(formField: self.formField, newText: text)
    }
}

// MARK: Basic text field logic
extension FormTextFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if formField == .personalHealthNumber {
            let currentString: NSString = textField.text! as NSString
            let newString: String = currentString.replacingCharacters(in: range, with: string) as String
            self.delegate?.textFieldTextDidChange(formField: self.formField, newText: newString)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.didFinishEditing(formField: self.formField, text: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: TextField Validation Error Message Handling
extension FormTextFieldView {
    // TODO Here
    
    
    // This is called when we have a regex error
//    private func adjustValidationError(error: String?) {
//        self.formTextFieldErrorLabel.isHidden = error == nil
//        self.formTextFieldErrorLabel.text = error
//    }
//
//    private func regexCheck(text: String?) -> Bool {
//        // TODO: Regex check here
//        guard let text = text else { return false }
//        // TODO: Apply regex to text
//        var validationError: String? = nil
//        adjustValidationError(error: validationError)
//        return validationError == nil
//    }
}
